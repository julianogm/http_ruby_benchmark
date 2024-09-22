require 'benchmark'
require 'memory_profiler'
require 'net/http'
require 'faraday'
require 'httparty'
require 'typhoeus'
require 'httpx'
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
  { name: 'HTTPX', method: -> { HTTPX.get(URL) } }
]

http_gems.each do |gem|
  puts "Benchmarking #{gem[:name]}:"
  
  time = Benchmark.realtime do
    report = MemoryProfiler.report do
      gem[:method].call
    end

    puts "Memory: #{report.total_allocated_memsize / 1024} KB"
    puts "Allocations: #{report.total_allocated}"
  end
  
  puts "Time: #{time.round(4)} seconds\n"
end

local_server.shutdown