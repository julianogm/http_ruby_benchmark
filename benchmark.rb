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
  { name: 'HTTPX', method: -> { HTTPX.get(URL) } },
  { name: 'HTTPrb', method: -> { HTTP.get(URL) } },
]

results_file = File.open('results.txt', 'w')
results_file.puts "HTTP RubyGems Benchmark - #{Date.today}"

http_gems.each do |gem|
  results_file.puts "\n#{gem[:name]}"
  
  time = Benchmark.realtime do
    report = MemoryProfiler.report do
      gem[:method].call
    end

    results_file.puts "Memory: #{report.total_allocated_memsize / 1024} KB"
    results_file.puts "Allocations: #{report.total_allocated}"
  end
  
  results_file.puts "Time: #{time.round(4)} seconds\n"
end

results_file.close

local_server.shutdown