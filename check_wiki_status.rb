#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'
require 'fileutils'

# Load release info data
release_info_path = File.join(__dir__, '_data', 'minecraft_mod_release_info.yml')
unless File.exist?(release_info_path)
  puts "Error: Could not find #{release_info_path}"
  exit 1
end

# Try loading with safe_load first (handles most YAML safely)
begin
  release_data = YAML.safe_load(File.read(release_info_path), permitted_classes: [Symbol])
rescue Psych::DisallowedClass
  # Fallback for older Ruby versions or if safe_load has issues
  release_data = YAML.load_file(release_info_path)
end

unless release_data.is_a?(Array) && release_data.any?
  puts "Error: Invalid release data format in #{release_info_path}"
  puts "Expected array with mod entries, got: #{release_data.class} - #{release_data.inspect}"
  exit 1
end

puts "=" * 80
puts "MINECRAFT MOD WIKI STATUS CHECKER"
puts "=" * 80
puts

total_versions = 0
versions_with_wiki = 0

# Parse each mod entry
release_data.each do |entry|
  entry.each do |mod_name, mod_info|
    minecraft_versions = mod_info['minecraft_versions'] || []
    total_versions += minecraft_versions.length

    puts "#{mod_name.upcase}"
    puts "-" * 40

    if minecraft_versions.empty?
      puts "  No versions found"
      puts
      next
    end

    minecraft_versions.each do |version|
      wiki_path = File.join(__dir__, 'minecraft-mod', mod_name, 'wiki', version, 'home.md')
      exists = File.exist?(wiki_path)
      versions_with_wiki += 1 if exists

      status = exists ? "✓" : "✗"
      puts "  #{status} #{version}"
    end

    puts
  end
end

puts "=" * 80
puts "SUMMARY"
puts "=" * 80
puts "Total versions: #{total_versions}"
puts "Versions with wiki: #{versions_with_wiki}"
puts "Versions without wiki: #{total_versions - versions_with_wiki}"
puts "Coverage: #{(versions_with_wiki.to_f / total_versions * 100).round(1)}%" if total_versions > 0
puts "=" * 80
