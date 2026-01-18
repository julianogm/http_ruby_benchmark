require 'benchmark'
require 'memory_profiler'
require 'net/http'
require 'faraday'
require 'httparty'
require 'typhoeus'
require 'httpx'
require 'http'
require 'webrick'

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

    puts "✓ #{gem[:name]} - #{avg_time}s"
  rescue => e
    results += "❌ Erro: #{e.message}\n"
    puts "❌ Erro ao testar #{gem[:name]}: #{e.message}"
  end
end

begin
  new_readme_content = readme_content[0..results_index + marker.length] + results
  File.write('README.md', new_readme_content)
  puts "\n✓ Resultados salvos em README.md"
rescue => e
  puts "❌ Erro ao salvar README.md: #{e.message}"
ensure
  local_server.shutdown
end
