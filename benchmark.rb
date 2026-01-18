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

PORT = 8000
REQUESTS_PER_GEM = 10

begin
  local_server = WEBrick::HTTPServer.new(
    Port: PORT,
    AccessLog: [],
    Logger: WEBrick::Log.new("/dev/null")
  )

  local_server.mount_proc '/' do |req, res|
    res.body = 'Http Gems Benchmark'
  end

  server_thread = Thread.new { local_server.start }
  sleep(2) # wait server start to run script
rescue => e
  puts "❌ Erro ao iniciar servidor: #{e.message}"
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
  puts "❌ Erro ao ler README.md: #{e.message}"
  local_server.shutdown
  exit 1
end

marker = "<!-- benchmark-results -->"
results_index = readme_content.index(marker)

results = "\n### HTTP RubyGems Benchmark - #{Date.today}\n"
json_results = {
  timestamp: Time.now.iso8601,
  date: Date.today.to_s,
  requests_per_gem: REQUESTS_PER_GEM,
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
    results += "❌ Erro: #{e.message}\n"
    json_results[:gems] << {
      name: gem[:name],
      error: e.message
    }
    puts "❌ Erro ao testar #{gem[:name]}: #{e.message}"
  end
end

begin
  new_readme_content = readme_content[0..results_index + marker.length] + results
  File.write('README.md', new_readme_content)
  puts "✓ Resultados salvos em README.md"

  # JSON report
  json_file = "benchmark_results_#{Date.today}.json"
  File.write(json_file, JSON.pretty_generate(json_results))
  puts "✓ Relatório JSON salvo em #{json_file}"

  File.write('benchmark_latest.json', JSON.pretty_generate(json_results))
  puts "✓ Últimos resultados salvos em benchmark_latest.json"

  # CSV report
  csv_file = "benchmark_results_#{Date.today}.csv"
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
  puts "✓ Relatório CSV salvo em #{csv_file}"

  csv_latest = "benchmark_latest.csv"
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
  puts "✓ Últimos resultados CSV salvos em #{csv_latest}"

rescue => e
  puts "❌ Erro ao salvar relatórios: #{e.message}"
ensure
  local_server.shutdown
end
