ORIGINAL_ARGV = ARGV.dup

require 'minitest/autorun'
require 'json'
require 'yaml'

# Mock Jekyll module since we're testing in isolation
module Jekyll
  class Generator
    def self.safe(val)
      # No-op for testing
    end

    def initialize(config = {})
      # Mock initialization
    end
  end

  def self.logger
    @logger ||= TestLogger.new
  end
end

class TestLogger
  def info(*args)
    puts "[INFO] #{args.join(' ')}"
  end

  def warn(*args)
    puts "[WARN] #{args.join(' ')}"
  end

  def error(*args)
    puts "[ERROR] #{args.join(' ')}"
  end
end

# Load the recipe generator with mocked dependencies
require_relative '../_plugins/recipe_generator'

class RecipeGeneratorDiscoveryTest < Minitest::Test
  DATA_RECIPES_GLOB = File.expand_path('../_data/*/recipes/**/*.{yml,yaml,json}', __dir__)

  def setup
    @generator = Jekyll::RecipeGenerator.new
  end

  def test_auto_discovery_normalizes_all_data_recipes
    recipe_files = Dir.glob(DATA_RECIPES_GLOB)
    refute_empty recipe_files, "No recipe files found using glob: #{DATA_RECIPES_GLOB}"

    failures = []
    discovered_recipe_count = 0

    recipe_files.each do |file|
      begin
        data = parse_recipe_file(file)
      rescue StandardError => e
        failures << "#{relative_path(file)}: failed to parse (#{e.class}: #{e.message})"
        next
      end

      default_key = File.basename(file, File.extname(file))

      collect_recipe_entries(data, [default_key]).each do |entry|
        recipe_data = entry[:recipe_data]
        next unless recipe_data.is_a?(Hash) && recipe_data['type'].is_a?(String)

        discovered_recipe_count += 1

        context = entry_context(file, entry)
        log_verbose("[DISCOVERY] mod=#{context[:mod]} type=#{context[:type]} key=#{context[:recipe_key]} source=#{context[:source]}")

        normalized = call_private(:normalize_recipe_data, entry[:recipe_key], recipe_data)

        if normalized.nil?
          failures << "#{context[:source]} :: #{context[:recipe_key]} (#{context[:type]}): normalization returned nil"
          next
        end

        begin
          assert normalized['type'], 'missing normalized type'
          assert normalized['input'], 'missing normalized input'
          assert normalized['output'], 'missing normalized output'
        rescue Minitest::Assertion => e
          failures << "#{context[:source]} :: #{context[:recipe_key]} (#{context[:type]}): #{e.message}"
        end
      end
    end

    assert_operator discovered_recipe_count, :>, 0, 'No recipes with a type were discovered in _data recipes directories'
    assert failures.empty?, "Auto-discovery normalization failures (#{failures.length}):\n#{failures.join("\n")}"
  end

  private

  def call_private(method_name, *args)
    @generator.send(method_name, *args)
  end

  def parse_recipe_file(file)
    content = File.read(file)
    ext = File.extname(file).downcase

    case ext
    when '.json'
      JSON.parse(content)
    when '.yml', '.yaml'
      YAML.safe_load(content, aliases: true)
    else
      raise "Unsupported recipe file extension: #{ext}"
    end
  end

  def collect_recipe_entries(node, trail = [], entries = [])
    case node
    when Hash
      if node['type'].is_a?(String)
        key = trail.last || 'unknown_recipe'
        entries << { recipe_key: key, recipe_data: node, trail: trail }
      else
        node.each do |key, value|
          collect_recipe_entries(value, trail + [key.to_s], entries)
        end
      end
    when Array
      node.each_with_index do |value, index|
        collect_recipe_entries(value, trail + [index.to_s], entries)
      end
    end

    entries
  end

  def entry_context(file, entry)
    rel = relative_path(file)
    mod = extract_mod_name(file)

    {
      source: rel,
      mod: mod,
      type: entry[:recipe_data]['type'],
      recipe_key: entry[:recipe_key]
    }
  end

  def extract_mod_name(file)
    match = file.match(%r{[\\/]_data[\\/]([^\\/]+)[\\/]recipes[\\/]})
    match ? match[1] : 'unknown_mod'
  end

  def relative_path(path)
    path.sub(File.expand_path('..', __dir__) + File::SEPARATOR, '')
  end

  def discovery_verbose?
    ENV['RECIPE_DISCOVERY_VERBOSE'] == '1' ||
      ENV['VERBOSE_RECIPES'] == '1' ||
      ORIGINAL_ARGV.include?('-v') ||
      ORIGINAL_ARGV.include?('--verbose')
  end

  def log_verbose(message)
    puts message if discovery_verbose?
  end
end
