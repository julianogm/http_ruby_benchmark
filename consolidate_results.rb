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
      puts "✓ Incluído cenário #{scenario}"
      files_to_delete << json_file
    else
      puts "⚠ Arquivo não encontrado: #{json_file}"
    end
  end

  # Save consolidated JSON
  output_file = "benchmark_consolidated.json"
  File.write(output_file, JSON.pretty_generate(consolidated))
  puts "✓ JSON consolidado salvo em #{output_file}"

  [consolidated, files_to_delete]
end

def consolidate_csv(consolidated, files_to_delete)
  csv_file = "benchmark_consolidated.csv"
  
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

  puts "✓ CSV consolidado salvo em #{csv_file}"
  
  SCENARIOS.each do |scenario|
    csv_name = "benchmark_latest_#{scenario}.csv"
    files_to_delete << csv_name if File.exist?(csv_name)
  end

  files_to_delete
end

def cleanup_individual_files(files_to_delete)
  puts "\n🗑 Limpando arquivos individuais..."
  
  files_to_delete.each do |file|
    if File.exist?(file)
      File.delete(file)
      puts "✓ Deletado: #{file}"
    end
  end

  ['benchmark_latest.json', 'benchmark_latest.csv'].each do |alias_file|
    if File.exist?(alias_file)
      File.delete(alias_file)
      puts "✓ Deletado: #{alias_file}"
    end
  end
  
  puts "✅ Limpeza concluída"
end

def update_readme(consolidated)
  puts "\n📝 Atualizando README.md com resultados consolidados..."

  begin
    readme_content = File.read('README.md')
  rescue => e
    puts "⚠ README.md não encontrado, ignorando atualização: #{e.message}"
    return
  end

  marker = "<!-- benchmark-results -->"
  results_index = readme_content.index(marker)

  unless results_index
    puts "⚠ Marker '#{marker}' não encontrado no README"
    return
  end

  results = "\n### HTTP RubyGems Benchmark - #{Date.today}\n"
  results += "#### Consolidated Results (Light + Normal + Heavy)\n\n"

  consolidated[:scenarios].each do |scenario, data|
    results += "**#{data[:name]}** (#{data[:payload_size] / 1024} KB, #{data[:requests_per_gem]} requisições)\n\n"
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
  puts "✓ README.md atualizado com dados consolidados"
end

puts "\n📊 Consolidando resultados dos 3 cenários...\n"

consolidated, files_to_delete = consolidate_json
consolidate_csv(consolidated, files_to_delete)
cleanup_individual_files(files_to_delete)
update_readme(consolidated)

puts "\n✅ Consolidação e atualização completas!"
puts "Arquivos finais:"
puts "  - benchmark_consolidated.json"
puts "  - benchmark_consolidated.csv"
puts "  - README.md (atualizado)"
