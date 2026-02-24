require 'minitest/autorun'
require 'json'

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

class RecipeGeneratorTest < Minitest::Test
  def setup
    @generator = Jekyll::RecipeGenerator.new
  end

  # Helper to call private methods for testing
  def call_private(method_name, *args)
    @generator.send(method_name, *args)
  end

  # ========== INGREDIENT FORMAT TESTS ==========
  
  def test_smelting_old_format_v121
    recipe = load_fixture('smelting_v121.json')
    result = call_private(:normalize_smelting, 'ring_candy_mold_v121', recipe)
    
    assert_instance_of Hash, result['input']
    assert_instance_of Hash, result['input']['item']
    assert_equal 'frightsdelight:unfired_ring_candy_mold', result['input']['item']['id']
    assert_equal 1, result['input']['item']['count']
    assert_equal 'frightsdelight:ring_candy_mold', result['output']['item']['id']
  end

  def test_smelting_new_format_v125
    recipe = load_fixture('smelting_v125.json')
    result = call_private(:normalize_smelting, 'ring_candy_mold_v125', recipe)
      
    assert_instance_of Hash, result['input']
    assert_instance_of Hash, result['input']['item']
    assert_equal 'frightsdelight:unfired_ring_candy_mold', result['input']['item']['id']
    assert_equal 1, result['input']['item']['count']
    assert_equal 'frightsdelight:ring_candy_mold', result['output']['item']['id']
  end

  def test_both_smelting_formats_produce_identical_output
    recipe_v121 = load_fixture('smelting_v121.json')
    recipe_v125 = load_fixture('smelting_v125.json')
    
    result_v121 = call_private(:normalize_smelting, 'test', recipe_v121)
    result_v125 = call_private(:normalize_smelting, 'test', recipe_v125)
    
    assert_equal result_v121['input'], result_v125['input']
    assert_equal result_v121['output'], result_v125['output']
  end

  # ========== DIRECT STRING INGREDIENT TESTS ==========
  
  def test_normalize_input_with_direct_item_string
    ingredient = 'minecraft:coal'
    result = call_private(:normalize_input, ingredient)
    
    assert_instance_of Hash, result
    assert_equal 'minecraft:coal', result['item']['id']
    assert_equal 1, result['item']['count']
  end

  def test_normalize_input_with_tag_string
    ingredient = '#minecraft:logs'
    result = call_private(:normalize_input, ingredient)
    
    assert_instance_of Hash, result
    assert_equal 'minecraft:logs', result['tag']['id']
    assert_equal 1, result['tag']['count']
  end

  def test_normalize_input_with_namespaced_tag
    ingredient = '#forge:storage_blocks/diamond'
    result = call_private(:normalize_input, ingredient)
    
    assert result['tag']
    assert_equal 'forge:storage_blocks/diamond', result['tag']['id']
  end

  # ========== HASH OBJECT INGREDIENT TESTS ==========

  def test_normalize_input_with_item_hash
    ingredient = { 'item' => 'minecraft:diamond', 'count' => 2 }
    result = call_private(:normalize_input, ingredient)
    
    assert_equal 'minecraft:diamond', result['item']['id']
    assert_equal 2, result['item']['count']
  end

  def test_normalize_input_with_tag_hash
    ingredient = { 'tag' => 'minecraft:planks', 'count' => 3 }
    result = call_private(:normalize_input, ingredient)
    
    assert_equal 'minecraft:planks', result['tag']['id']
    assert_equal 3, result['tag']['count']
  end

  def test_normalize_input_with_fluid
    ingredient = { 'fluid' => 'minecraft:water', 'amount' => 1000 }
    result = call_private(:normalize_input, ingredient)
    
    assert_equal 'minecraft:water', result['fluid']['id']
    assert_equal 1000, result['fluid']['amount']
  end

  def test_normalize_input_with_wrapped_ingredient
    ingredient = { 'ingredient' => 'minecraft:dirt' }
    result = call_private(:normalize_input, ingredient)
    
    assert_equal 'minecraft:dirt', result['item']['id']
  end

  # ========== RECIPE TYPE TESTS ==========

  def test_normalize_crafting_shaped
    recipe = load_fixture('crafting_shaped.json')
    result = call_private(:normalize_crafting_shaped, 'furnace', recipe)
    
    assert_equal 'minecraft:crafting_shaped', result['type']
    assert_equal 'misc', result['category']
    assert result['pattern']
    assert result['input']
    assert_equal 'minecraft:furnace', result['output']['item']['id']
  end

  def test_normalize_crafting_shapeless
    recipe = load_fixture('crafting_shapeless.json')
    result = call_private(:normalize_crafting_shapeless, 'chest', recipe)
    
    assert_equal 'minecraft:crafting_shapeless', result['type']
    assert_equal 'misc', result['category']
    assert_instance_of Array, result['input']
    assert result['input'].length > 0
  end

  def test_normalize_smoking
    recipe = load_fixture('smoking.json')
    result = call_private(:normalize_smoking, 'cooked_beef', recipe)
    
    assert_equal 'minecraft:smoking', result['type']
    assert_equal 'food', result['category']
    assert_equal 100, result['cookingtime']
    assert_equal 0.35, result['experience']
    assert_equal 'minecraft:cooked_beef', result['output']['item']['id']
  end

  def test_normalize_create_mixing
    recipe = load_fixture('create_mixing_v1201.json')
    result = call_private(:normalize_create_mixing, 'garlic_chop', recipe)

    assert_equal 'create:mixing', result['type']
    assert_instance_of Array, result['load_conditions']
    assert_equal 'fabric:any_mod_loaded', result['load_conditions'][0]['condition']
    assert_instance_of Array, result['input']
    assert_equal 'ubesdelight:garlic', result['input'][0]['item']['id']
    assert_equal 1, result['input'][0]['item']['count']
    assert_instance_of Array, result['output']
    assert_equal 'ubesdelight:garlic_chop', result['output'][0]['item']['id']
    assert_equal 2, result['output'][0]['item']['count']
  end

  def test_normalize_create_milling
    recipe = load_fixture('create_milling_v1201.json')
    result = call_private(:normalize_create_milling, 'wild_garlic', recipe)

    assert_equal 'create:milling', result['type']
    assert_equal 50, result['processing_time']
    assert_instance_of Array, result['load_conditions']
    assert_equal 'fabric:any_mod_loaded', result['load_conditions'][0]['condition']
    assert_instance_of Array, result['input']
    assert_equal 'ubesdelight:wild_garlic', result['input'][0]['item']['id']
    assert_equal 1, result['input'][0]['item']['count']
    assert_instance_of Array, result['output']
    assert_equal 2, result['output'].length
    assert_equal 'ubesdelight:garlic', result['output'][0]['item']['id']
    assert_equal 1, result['output'][0]['item']['count']
    assert_equal 'minecraft:pink_dye', result['output'][1]['item']['id']
    assert_equal 1, result['output'][1]['item']['count']
  end

  def test_normalize_ud_baking_mat
    recipe = load_fixture('ud_baking_mat_v1201.json')
    result = call_private(:normalize_ud_baking_mat, 'apple_pie', recipe)

    assert_equal 'ubesdelight:baking_mat', result['type']
    assert_equal 'c:tools/rolling_pins', result['tool']
    assert_instance_of Array, result['input']
    assert_equal 4, result['input'].length
    assert_equal 'minecraft:apple', result['input'][0]['item']['id']
    assert_equal 3, result['input'][0]['item']['count']
    assert_equal 'minecraft:wheat', result['input'][1]['item']['id']
    assert_equal 3, result['input'][1]['item']['count']
    assert_equal 'farmersdelight:pie_crust', result['input'][2]['item']['id']
    assert_equal 1, result['input'][2]['item']['count']
    assert_equal 'c:tea_ingredients/sweet/weak', result['input'][3]['tag']['id']
    assert_equal 2, result['input'][3]['tag']['count']
    assert_equal [], result['processing_stages']
    assert_instance_of Array, result['output']
    assert_equal 'farmersdelight:apple_pie', result['output'][0]['item']['id']
    assert_equal 1, result['output'][0]['item']['count']
    assert_equal 'farmersdelight:apple_pie', result['output'][1]['item']['id']
    assert_equal 0.5, result['output'][1]['chance']
  end

  def test_normalize_fd_cooking
    recipe = load_fixture('fd_cooking_v1201.json')
    result = call_private(:normalize_fd_cooking, 'bangsilog', recipe)

    assert_equal 'farmersdelight:cooking', result['type']
    assert_equal 'meals', result['recipe_book_tab']
    assert_equal 3.0, result['experience']
    assert_instance_of Array, result['input']
    assert_equal 'c:foods/raw_fishes', result['input'][0]['tag']['id']
    assert_equal 1, result['input'][0]['tag']['count']
    assert_equal 'ubesdelight:sinangag', result['input'][1]['item']['id']
    assert_equal 1, result['input'][1]['item']['count']
    assert_equal 'c:foods/cooked_meats/cooked_eggs', result['input'][2]['tag']['id']
    assert_equal 1, result['input'][2]['tag']['count']
    assert_equal 'ubesdelight:bangsilog', result['output']['item']['id']
    assert_equal 1, result['output']['item']['count']
  end

  def test_normalize_fd_cutting
    recipe = load_fixture('fd_cutting_v1201.json')
    result = call_private(:normalize_fd_cutting, 'lemongrass', recipe)

    assert_equal 'farmersdelight:cutting', result['type']
    assert_equal 'c:tools/knives', result['tool']
    assert_instance_of Array, result['input']
    assert_equal 'ubesdelight:wild_lemongrass', result['input'][0]['item']['id']
    assert_equal 1, result['input'][0]['item']['count']
    assert_instance_of Array, result['output']
    assert_equal 3, result['output'].length
    assert_equal 'ubesdelight:lemongrass', result['output'][0]['item']['id']
    assert_equal 'minecraft:lime_dye', result['output'][1]['item']['id']
    assert_equal 'minecraft:lime_dye', result['output'][2]['item']['id']
    assert_equal 0.5, result['output'][2]['chance']
  end

  # ========== EDGE CASES & ERROR HANDLING ==========

  def test_ingredient_with_default_count
    ingredient = { 'item' => 'minecraft:stone' }
    result = call_private(:normalize_input, ingredient)
    
    assert_equal 1, result['item']['count']
  end

  def test_fluid_with_default_amount
    ingredient = { 'fluid' => 'minecraft:lava' }
    result = call_private(:normalize_input, ingredient)
    
    assert_equal 1, result['fluid']['amount']
  end

  def test_extract_ingredient_with_direct_format
    recipe_data = {
      'type' => 'minecraft:smelting',
      'ingredient' => 'minecraft:raw_copper',
      'result' => { 'item' => 'minecraft:copper_ingot' }
    }
    result = call_private(:extract_ingredient, recipe_data)
    
    assert_equal 'minecraft:raw_copper', result
  end

  # ========== HELPER METHODS ==========

  private

  def load_fixture(filename)
    path = File.expand_path("../fixtures/recipes/#{filename}", __FILE__)
    JSON.parse(File.read(path))
  rescue Errno::ENOENT
    raise "Fixture file not found: #{path}"
  rescue JSON::ParserError => e
    raise "Invalid JSON in fixture #{filename}: #{e.message}"
  end
end
