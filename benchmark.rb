require 'benchmark'
require 'memory_profiler'
require 'net/http'
require 'faraday'
require 'httparty'
require 'typhoeus'
require 'httpx'
require 'http'
require 'webrick'
require 'json'
require 'csv'
require 'date'

SCENARIOS = {
  'light' => {
    name: 'Light (1 KB)',
    payload_size: 1024,
    requests: 50,
    description: 'Small payloads - tests HTTP client overhead'
  },
  'normal' => {
    name: 'Normal (100 KB)',
    payload_size: 100 * 1024,
    requests: 30,
    description: 'Medium payloads - typical API responses'
  },
  'heavy' => {
    name: 'Heavy (1 MB)',
    payload_size: 1024 * 1024,
    requests: 10,
    description: 'Large payloads - high volume scenarios'
  }
}

SCENARIO = ARGV[0] || 'normal'

if !SCENARIOS.key?(SCENARIO)
  puts "❌ Invalid scenario: #{SCENARIO}"
  puts "Available scenarios: #{SCENARIOS.keys.join(', ')}"
  exit 1
end

CURRENT_SCENARIO = SCENARIOS[SCENARIO]
REQUESTS_PER_GEM = CURRENT_SCENARIO[:requests]
PAYLOAD_SIZE = CURRENT_SCENARIO[:payload_size]

puts "\n📊 Benchmark - Scenario: #{CURRENT_SCENARIO[:name]}"
puts "   #{CURRENT_SCENARIO[:description]}"
puts "   Requests per gem: #{REQUESTS_PER_GEM}"
puts "   Payload size: #{PAYLOAD_SIZE / 1024} KB\n\n"

PORT = 8000

begin
  local_server = WEBrick::HTTPServer.new(
    Port: PORT,
    AccessLog: [],
    Logger: WEBrick::Log.new("/dev/null")
  )

  payload = 'x' * PAYLOAD_SIZE

  local_server.mount_proc '/' do |req, res|
    res.body = payload
  end

  server_thread = Thread.new { local_server.start }
  sleep(2) # wait server start to run script
rescue => e
  puts "❌ Error starting server: #{e.message}"
  exit 1
end

URL = "http://localhost:#{PORT}"

http_gems = [
  { name: 'Net::HTTP', method: -> { Net::HTTP.get(URI(URL)) } },
  { name: 'Faraday', method: -> { Faraday.get(URL) } },
  { name: 'HTTParty', method: -> { HTTParty.get(URL) } },
  { name: 'Typhoeus', method: -> { Typhoeus.get(URL) } },
  { name: 'httpx', method: -> { HTTPX.get(URL) } },
  { name: 'http.rb', method: -> { HTTP.get(URL) } },
]

begin
  readme_content = File.read('README.md')
rescue => e
  puts "❌ Error reading README.md: #{e.message}"
  local_server.shutdown
  exit 1
end

marker = "<!-- benchmark-results -->"
results_index = readme_content.index(marker)

results = "\n### HTTP RubyGems Benchmark - #{Date.today} (#{CURRENT_SCENARIO[:name]})\n"
json_results = {
  timestamp: Time.now.iso8601,
  date: Date.today.to_s,
  scenario: SCENARIO,
  scenario_name: CURRENT_SCENARIO[:name],
  requests_per_gem: REQUESTS_PER_GEM,
  payload_size: PAYLOAD_SIZE,
  gems: []
}

http_gems.each do |gem|
  begin
    results += "#### #{gem[:name]}\n"

    total_time = 0
    total_memory = 0
    total_allocations = 0

    REQUESTS_PER_GEM.times do
      time = Benchmark.realtime do
        report = MemoryProfiler.report do
          gem[:method].call
        end

        total_memory += report.total_allocated_memsize
        total_allocations += report.total_allocated
      end
      total_time += time
    end

    avg_memory = (total_memory / REQUESTS_PER_GEM) / 1024
    avg_allocations = (total_allocations / REQUESTS_PER_GEM).round(0)
    avg_time = (total_time / REQUESTS_PER_GEM).round(4)

    results += "Memory: #{avg_memory} KB <br />"
    results += "Allocations: #{avg_allocations} <br />"
    results += "Time: #{avg_time} seconds \n"

    json_results[:gems] << {
      name: gem[:name],
      memory_kb: avg_memory,
      allocations: avg_allocations,
      time_seconds: avg_time
    }

    puts "✓ #{gem[:name]} - #{avg_time}s"
  rescue => e
    results += "❌ Error: #{e.message}\n"
    json_results[:gems] << {
      name: gem[:name],
      error: e.message
    }
    puts "❌ Error testing #{gem[:name]}: #{e.message}"
  end
end

begin
  new_readme_content = readme_content[0..results_index + marker.length] + results
  File.write('README.md', new_readme_content)
  puts "\n✓ Results saved to README.md"

  # JSON report with scenario
  json_file = "benchmark_results_#{SCENARIO}_#{Date.today}.json"
  File.write(json_file, JSON.pretty_generate(json_results))
  puts "✓ JSON report saved to #{json_file}"

  json_latest = "benchmark_latest_#{SCENARIO}.json"
  File.write(json_latest, JSON.pretty_generate(json_results))
  puts "✓ Latest JSON results saved to #{json_latest}"

  if SCENARIO == 'normal'
    File.write('benchmark_latest.json', JSON.pretty_generate(json_results))
    puts "✓ Latest results saved to benchmark_latest.json"
  end

  # CSV report
  csv_file = "benchmark_results_#{SCENARIO}_#{Date.today}.csv"
  CSV.open(csv_file, 'w') do |csv|
    csv << ['Gem', 'Memory (KB)', 'Allocations', 'Time (seconds)']
    json_results[:gems].each do |gem|
      if gem[:error]
        csv << [gem[:name], 'ERROR', gem[:error], '']
      else
        csv << [gem[:name], gem[:memory_kb], gem[:allocations], gem[:time_seconds]]
      end
    end
  end
  puts "✓ CSV report saved to #{csv_file}"

  # Latest CSV for this scenario
  csv_latest = "benchmark_latest_#{SCENARIO}.csv"
  CSV.open(csv_latest, 'w') do |csv|
    csv << ['Gem', 'Memory (KB)', 'Allocations', 'Time (seconds)']
    json_results[:gems].each do |gem|
      if gem[:error]
        csv << [gem[:name], 'ERROR', gem[:error], '']
      else
        csv << [gem[:name], gem[:memory_kb], gem[:allocations], gem[:time_seconds]]
      end
    end
  end
  puts "✓ Latest CSV results saved to #{csv_latest}"

  if SCENARIO == 'normal'
    CSV.open('benchmark_latest.csv', 'w') do |csv|
      csv << ['Gem', 'Memory (KB)', 'Allocations', 'Time (seconds)']
      json_results[:gems].each do |gem|
        if gem[:error]
          csv << [gem[:name], 'ERROR', gem[:error], '']
        else
          csv << [gem[:name], gem[:memory_kb], gem[:allocations], gem[:time_seconds]]
        end
      end
    end
    puts "✓ Latest results saved to benchmark_latest.csv"
  end

rescue => e
  puts "❌ Error saving reports: #{e.message}"
ensure
  local_server.shutdown
end

puts "\n✅ Benchmark complete!"
