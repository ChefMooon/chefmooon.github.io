#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'
require 'fileutils'

WIKI_FILES = [
  ['Home', 'home.md'],
  ['Item Details', 'item-details.md'],
  ['Block Details', 'block-details.md'],
  ['Recipes', 'recipes.md']
].freeze

LOADER_DIRS = %w[core fabric neoforge].freeze

def version_to_data_dir(version)
  version.tr('.', '-')
end

def mod_data_candidates(mod_name)
  [
    mod_name,
    mod_name.delete('-'),
    mod_name.tr('-', '_')
  ].uniq
end

def count_json_files(path)
  Dir.glob(File.join(path, '**', '*.json')).count
end

def find_recipe_base_path(repo_root, mod_name, version)
  version_dir = version_to_data_dir(version)

  mod_data_candidates(mod_name).each do |candidate|
    path = File.join(repo_root, '_data', candidate, 'recipes', version_dir)
    return path if Dir.exist?(path)
  end

  nil
end

def recipe_counts_for_version(repo_root, mod_name, version)
  base_path = find_recipe_base_path(repo_root, mod_name, version)
  return { type: :none, total: 0 } if base_path.nil?

  has_loader_structure = LOADER_DIRS.any? { |loader| Dir.exist?(File.join(base_path, loader)) }

  if has_loader_structure
    counts = {}

    LOADER_DIRS.each do |loader|
      loader_path = File.join(base_path, loader)
      counts[loader] = Dir.exist?(loader_path) ? count_json_files(loader_path) : 0
    end

    { type: :loaders, counts: counts, total: counts.values.sum }
  else
    total = count_json_files(base_path)
    { type: :single, total: total }
  end
end

# Load release info data
REPO_ROOT = File.expand_path(File.join(__dir__, '..'))
release_info_path = File.join(REPO_ROOT, '_data', 'minecraft_mod_release_info.yml')
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
versions_with_recipes = 0

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
      puts "  #{version}"

      wiki_statuses = WIKI_FILES.map do |label, filename|
        wiki_path = File.join(REPO_ROOT, 'minecraft-mod', mod_name, 'wiki', version, filename)
        exists = File.exist?(wiki_path)
        "#{exists ? '✓' : '✗'} #{label}"
      end

      home_exists = File.exist?(File.join(REPO_ROOT, 'minecraft-mod', mod_name, 'wiki', version, 'home.md'))
      versions_with_wiki += 1 if home_exists

      puts "      #{wiki_statuses.join(' ')}"

      recipe_counts = recipe_counts_for_version(REPO_ROOT, mod_name, version)
      versions_with_recipes += 1 if recipe_counts[:total].positive?

      case recipe_counts[:type]
      when :loaders
        LOADER_DIRS.each do |loader|
          count = recipe_counts[:counts][loader]
          status = if count.positive?
                     "✓ #{count} recipes found"
                   else
                     '✗ no recipes found'
                   end
          puts "      #{loader}: #{status}"
        end
      else
        if recipe_counts[:total].positive?
          puts "      ✓ #{recipe_counts[:total]} recipes found"
        else
          puts '      ✗ no recipes found'
        end
      end
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
puts "Versions with recipe data: #{versions_with_recipes}"
puts "Versions without recipe data: #{total_versions - versions_with_recipes}"
puts "Recipe data coverage: #{(versions_with_recipes.to_f / total_versions * 100).round(1)}%" if total_versions > 0
puts "=" * 80
