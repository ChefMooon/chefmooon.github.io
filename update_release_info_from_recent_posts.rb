#!/usr/bin/env ruby
# frozen_string_literal: true

require 'date'
require 'optparse'
require 'set'
require 'yaml'

ROOT_DIR = File.expand_path(__dir__)
POSTS_GLOB = File.join(ROOT_DIR, '_posts', '*', '*.md')
RELEASE_INFO_PATH = File.join(ROOT_DIR, '_data', 'minecraft_mod_release_info.yml')

def normalize_mod_id(value)
  value.to_s.strip.downcase.tr('_', '-')
end

def canonical_mod_lookup_key(value)
  normalize_mod_id(value).gsub(/[^a-z0-9]/, '')
end

def normalize_version(value)
  value.to_s.strip
end

def split_versions(version_string)
  version_string.to_s.strip.split(/[\s,]+/).map { |v| normalize_version(v) }.reject(&:empty?)
end

def version_sort_key(version)
  version.split('.').map do |part|
    if part.match?(/\A\d+\z/)
      [0, part.to_i]
    else
      [1, part]
    end
  end
end

def extract_frontmatter(post_path)
  content = File.read(post_path)
  match = content.match(/\A---\s*\r?\n(.*?)\r?\n---\s*(?:\r?\n|\z)/m)
  return {} unless match

  YAML.safe_load(match[1], permitted_classes: [Date, Time], aliases: true) || {}
rescue Psych::Exception => e
  warn "Skipping #{post_path}: invalid frontmatter (#{e.class}: #{e.message})"
  {}
end

def extract_post_date(post_path)
  file_name = File.basename(post_path)
  date_part = file_name[/\A(\d{4}-\d{2}-\d{2})-/, 1]
  return Date.new(1970, 1, 1) unless date_part

  Date.strptime(date_part, '%Y-%m-%d')
rescue ArgumentError
  Date.new(1970, 1, 1)
end

def recent_posts(limit)
  Dir.glob(POSTS_GLOB)
     .select { |path| File.file?(path) }
     .sort_by { |path| [extract_post_date(path), File.basename(path)] }
     .reverse
     .take(limit)
end

def read_release_info
  unless File.exist?(RELEASE_INFO_PATH)
    raise "Could not find #{RELEASE_INFO_PATH}"
  end

  data = YAML.safe_load(File.read(RELEASE_INFO_PATH), permitted_classes: [Date, Time], aliases: true)
  unless data.is_a?(Array)
    raise "Expected array format in #{RELEASE_INFO_PATH}, got #{data.class}"
  end

  ordered_keys = []
  version_sets = {}
  has_malformed_entries = false

  data.each do |entry|
    next unless entry.is_a?(Hash) && entry.size == 1

    mod_key, mod_info = entry.first
    ordered_keys << mod_key

    raw_versions = Array(mod_info && mod_info['minecraft_versions']) || []
    parsed_versions = Set.new
    raw_versions.each do |version_entry|
      split_result = split_versions(version_entry)
      if split_result.length > 1 || (version_entry.to_s.include?(' ') && split_result.length > 0)
        has_malformed_entries = true
      end
      split_result.each { |v| parsed_versions.add(v) }
    end

    version_sets[mod_key] = parsed_versions
  end

  [ordered_keys, version_sets, has_malformed_entries]
end

def write_release_info(ordered_keys, version_sets)
  output_lines = []

  ordered_keys.each_with_index do |mod_key, index|
    output_lines << "- #{mod_key}:"
    output_lines << '    minecraft_versions:'

    sorted_versions = version_sets.fetch(mod_key, Set.new).to_a.sort_by { |version| version_sort_key(version) }
    sorted_versions.each do |version|
      output_lines << "      - #{version}"
    end

    output_lines << '' if index < ordered_keys.length - 1
  end

  File.write(RELEASE_INFO_PATH, "#{output_lines.join("\n")}\n")
end

def collect_versions_from_posts(posts)
  versions_by_mod = Hash.new { |hash, key| hash[key] = Set.new }

  posts.each do |post_path|
    frontmatter = extract_frontmatter(post_path)
    mod_id = normalize_mod_id(frontmatter['mod_id'])
    mod_id = normalize_mod_id(File.basename(File.dirname(post_path))) if mod_id.empty?

    raw_versions = frontmatter['minecraft_version']
    parsed_versions = case raw_versions
                      when Array
                        raw_versions
                      when String
                        split_versions(raw_versions)
                      else
                        []
                      end

    parsed_versions.each do |version|
      versions_by_mod[mod_id] << version
    end
  end

  versions_by_mod
end

options = {
  limit: 5,
  dry_run: false
}

OptionParser.new do |parser|
  parser.banner = 'Usage: ruby update_release_info_from_recent_posts.rb [options]'

  parser.on('--limit N', Integer, 'Number of most recent posts to inspect (default: 5)') do |value|
    options[:limit] = value
  end

  parser.on('--dry-run', 'Show proposed changes without writing the YAML file') do
    options[:dry_run] = true
  end
end.parse!

if options[:limit] <= 0
  warn 'Error: --limit must be greater than 0'
  exit 1
end

posts = recent_posts(options[:limit])
if posts.empty?
  warn 'No posts found in _posts/*/*.md'
  exit 1
end

ordered_keys, version_sets, has_malformed_entries = read_release_info
normalized_existing_keys = {}

ordered_keys.each do |mod_key|
  normalized_existing_keys[canonical_mod_lookup_key(mod_key)] ||= mod_key
end

versions_from_posts = collect_versions_from_posts(posts)
changes = Hash.new { |hash, key| hash[key] = [] }

versions_from_posts.each do |normalized_mod_id, discovered_versions|
  target_key = normalized_existing_keys[canonical_mod_lookup_key(normalized_mod_id)]

  unless target_key
    target_key = normalized_mod_id
    ordered_keys << target_key
    version_sets[target_key] = Set.new
    normalized_existing_keys[canonical_mod_lookup_key(normalized_mod_id)] = target_key
  end

  discovered_versions.each do |version|
    next if version_sets[target_key].include?(version)

    version_sets[target_key] << version
    changes[target_key] << version
  end
end

if changes.empty? && !has_malformed_entries
  puts "No updates needed. Checked #{posts.length} recent posts."
  exit 0
end

if changes.any?
  changes.each do |mod_key, added_versions|
    sorted_added = added_versions.sort_by { |version| version_sort_key(version) }
    puts "#{mod_key}: added #{sorted_added.join(', ')}"
  end
elsif has_malformed_entries
  puts "Normalizing malformed version entries."
end

if options[:dry_run]
  puts 'Dry-run complete. No files were modified.'
  exit 0
end

write_release_info(ordered_keys, version_sets)
if changes.any?
  puts "Updated #{RELEASE_INFO_PATH} from #{posts.length} recent posts."
elsif has_malformed_entries
  puts "Normalized #{RELEASE_INFO_PATH} (fixed malformed version entries)."
end
