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
local_server = WEBrick::HTTPServer.new(Port: PORT)

local_server.mount_proc '/' do |req, res|
  res.body = 'Http Gems Benchmark'
end

Thread.new { local_server.start }
sleep(2) # wait server start to run script

URL = "http://localhost:#{PORT}"

http_gems = [
  { name: 'Net::HTTP', method: -> { Net::HTTP.get(URI(URL)) } },
  { name: 'Faraday', method: -> { Faraday.get(URL) } },
  { name: 'HTTParty', method: -> { HTTParty.get(URL) } },
  { name: 'Typhoeus', method: -> { Typhoeus.get(URL) } },
  { name: 'httpx', method: -> { HTTPX.get(URL) } },
  { name: 'http.rb', method: -> { HTTP.get(URL) } },
]


readme_content = File.read('README.md')

marker = "<!-- benchmark-results -->"
results_index = readme_content.index(marker)

results = "\n### HTTP RubyGems Benchmark - #{Date.today}\n"

http_gems.each do |gem|
  results += "#### #{gem[:name]}\n"

  time = Benchmark.realtime do
    report = MemoryProfiler.report do
      gem[:method].call
    end

    results += "Memory: #{report.total_allocated_memsize / 1024} KB <br />"
    results += "Allocations: #{report.total_allocated} <br />"
  end

  results += "Time: #{time.round(4)} seconds \n"
end

new_readme_content = readme_content[0..results_index + marker.length] + results
File.write('README.md', new_readme_content)

local_server.shutdown
