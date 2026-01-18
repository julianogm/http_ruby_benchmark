#!/usr/bin/env ruby

require 'json'
require 'csv'
require 'time'
require 'date'


SCENARIOS = ['light', 'normal', 'heavy']

def consolidate_json
  consolidated = {
    timestamp: Time.now.iso8601,
    date: Date.today.to_s,
    scenarios: {}
  }

  files_to_delete = []

  SCENARIOS.each do |scenario|
    json_file = "benchmark_latest_#{scenario}.json"
    
    if File.exist?(json_file)
      data = JSON.parse(File.read(json_file))
      consolidated[:scenarios][scenario.to_sym] = {
        name: data['scenario_name'],
        payload_size: data['payload_size'],
        requests_per_gem: data['requests_per_gem'],
        gems: data['gems']
      }
      puts "✓ Scenario #{scenario} included"
      files_to_delete << json_file
    else
      puts "⚠ File not found: #{json_file}"
    end
  end

  # Save consolidated JSON
  output_file = "benchmark_results.json"
  File.write(output_file, JSON.pretty_generate(consolidated))
  puts "✓ Consolidated JSON saved to #{output_file}"

  [consolidated, files_to_delete]
end

def consolidate_csv(consolidated, files_to_delete)
  csv_file = "benchmark_results.csv"
  
  CSV.open(csv_file, 'w') do |csv|
    # Header
    csv << ['Scenario', 'Gem', 'Memory (KB)', 'Allocations', 'Time (seconds)']
    
    # Rows
    consolidated[:scenarios].each do |scenario, data|
      scenario_name = data[:name]
      data[:gems].each do |gem|
        if gem['error']
          csv << [scenario_name, gem['name'], 'ERROR', gem['error'], '']
        else
          csv << [scenario_name, gem['name'], gem['memory_kb'], gem['allocations'], gem['time_seconds']]
        end
      end
    end
  end

  puts "✓ Consolidated CSV saved to #{csv_file}"
  
  SCENARIOS.each do |scenario|
    csv_name = "benchmark_latest_#{scenario}.csv"
    files_to_delete << csv_name if File.exist?(csv_name)
  end

  files_to_delete
end

def cleanup_individual_files(files_to_delete)
  puts "\n🗑 Cleaning up individual files..."
  
  files_to_delete.each do |file|
    if File.exist?(file)
      File.delete(file)
      puts "✓ Deleted: #{file}"
    end
  end

  ['benchmark_latest.json', 'benchmark_latest.csv'].each do |alias_file|
    if File.exist?(alias_file)
      File.delete(alias_file)
      puts "✓ Deleted: #{alias_file}"
    end
  end
  
  puts "✅ Cleanup complete"
end

def update_readme(consolidated)
  puts "\n📝 Updating README.md with consolidated results..."

  begin
    readme_content = File.read('README.md')
  rescue => e
    puts "⚠ README.md not found, skipping update: #{e.message}"
    return
  end

  marker = "<!-- benchmark-results -->"
  results_index = readme_content.index(marker)

  unless results_index
    puts "⚠ Marker '#{marker}' not found in README"
    return
  end

  results = "\n### HTTP RubyGems Benchmark - #{Date.today}\n"
  results += "#### Consolidated Results (Light + Normal + Heavy)\n\n"

  consolidated[:scenarios].each do |scenario, data|
    results += "**#{data[:name]}** (#{data[:payload_size] / 1024} KB, #{data[:requests_per_gem]} requests)\n\n"
    results += "| Gem | Memory (KB) | Allocations | Time (s) |\n"
    results += "|-----|-----------|------------|----------|\n"

    data[:gems].each do |gem|
      if gem['error']
        results += "| #{gem['name']} | ERROR | #{gem['error']} | - |\n"
      else
        results += "| #{gem['name']} | #{gem['memory_kb']} | #{gem['allocations']} | #{gem['time_seconds']} |\n"
      end
    end

    results += "\n"
  end

  new_readme_content = readme_content[0..results_index + marker.length] + results
  File.write('README.md', new_readme_content)
  puts "✓ README.md updated with consolidated results"
end

puts "\n📊 Consolidating results from 3 scenarios...\n"

consolidated, files_to_delete = consolidate_json
consolidate_csv(consolidated, files_to_delete)
cleanup_individual_files(files_to_delete)
update_readme(consolidated)

puts "\n✅ Consolidation and update complete!"
puts "Final files:"
puts "  - benchmark_results.json"
puts "  - benchmark_results.csv"
puts "  - README.md (updated)"
