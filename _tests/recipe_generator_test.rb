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

  def test_normalize_create_milling_v12111
    recipe = load_fixture('create_milling_v12111.json')
    result = call_private(:normalize_create_milling, 'wild_garlic_v12111', recipe)

    assert_equal 'create:milling', result['type']
    assert_equal 50, result['processing_time']
    assert_instance_of Array, result['load_conditions']
    assert_equal 'fabric:all_mods_loaded', result['load_conditions'][0]['condition']
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

  def test_both_create_milling_versions_normalize_correctly
    recipe_v1201 = load_fixture('create_milling_v1201.json')
    recipe_v12111 = load_fixture('create_milling_v12111.json')
    
    result_v1201 = call_private(:normalize_create_milling, 'test', recipe_v1201)
    result_v12111 = call_private(:normalize_create_milling, 'test', recipe_v12111)
    
    # Both should have the required fields
    assert result_v1201['type']
    assert result_v1201['processing_time']
    assert result_v1201['input']
    assert result_v1201['output']
    
    assert result_v12111['type']
    assert result_v12111['processing_time']
    assert result_v12111['input']
    assert result_v12111['output']
    
    # Both should be arrays
    assert_instance_of Array, result_v1201['input']
    assert_instance_of Array, result_v1201['output']
    assert_instance_of Array, result_v12111['input']
    assert_instance_of Array, result_v12111['output']
  end

  def test_normalize_create_mixing_new_schema
    recipe = load_fixture('create_mixing_v12111.json')
    result = call_private(:normalize_create_mixing, 'rotten_flesh_syrup', recipe)

    assert_equal 'create:mixing', result['type']
    assert_instance_of Array, result['load_conditions']
    assert_instance_of Array, result['input']
    assert_instance_of Array, result['output']
    
    # Should have items from ingredients
    assert result['input'].any? { |ing| ing['item'] && ing['item']['id'] == 'minecraft:rotten_flesh' }
    assert result['input'].any? { |ing| ing['item'] && ing['item']['id'] == 'minecraft:sugar' }
    
    # Should have fluid from fluid_ingredients
    assert result['input'].any? { |ing| ing['fluid'] && ing['fluid']['id'] == 'minecraft:water' }
    
    # Should have fluid output from fluid_results
    assert result['output'].any? { |out| out['fluid'] && out['fluid']['id'] == 'frightsdelight:rotten_flesh_syrup' }
    assert_equal 81000, result['output'].find { |out| out['fluid'] }['fluid']['amount']
  end

  def test_normalize_create_emptying_new_schema
    recipe = load_fixture('create_emptying_v12111.json')
    result = call_private(:normalize_create_emptying, 'water_emptying', recipe)

    assert_equal 'create:emptying', result['type']
    assert_instance_of Array, result['input']
    assert_instance_of Array, result['output']
    
    # Should have fluid input from fluid_ingredients
    assert result['input'].any? { |ing| ing['fluid'] && ing['fluid']['id'] == 'minecraft:water' }
    assert_equal 250, result['input'].find { |ing| ing['fluid'] }['fluid']['amount']
    
    # Should have item output from results
    assert result['output'].any? { |out| out['item'] && out['item']['id'] == 'minecraft:glass_bottle' }
  end

  def test_normalize_create_filling_new_schema
    recipe = load_fixture('create_filling_v12111.json')
    result = call_private(:normalize_create_filling, 'water_filling', recipe)

    assert_equal 'create:filling', result['type']
    assert_instance_of Array, result['input']
    assert_instance_of Array, result['output']
    
    # Should have item from ingredients
    assert result['input'].any? { |ing| ing['item'] && ing['item']['id'] == 'minecraft:glass_bottle' }
    
    # Should have fluid from fluid_ingredients
    assert result['input'].any? { |ing| ing['fluid'] && ing['fluid']['id'] == 'minecraft:water' }
    assert_equal 250, result['input'].find { |ing| ing['fluid'] }['fluid']['amount']
    
    # Should have item output from results
    assert result['output'].any? { |out| out['item'] && out['item']['id'] == 'minecraft:water_bucket' }
  end

  def test_validate_create_mixing_old_schema
    recipe = {
      'type' => 'create:mixing',
      'ingredients' => ['minecraft:sand', 'minecraft:gravel'],
      'results' => [{'item' => 'minecraft:dirt'}]
    }
    validation = call_private(:validate_create_recipe, 'test_mixing', recipe, 'create:mixing')
    
    assert_equal true, validation[:valid]
  end

  def test_validate_create_mixing_new_schema
    recipe = {
      'type' => 'create:mixing',
      'ingredients' => [],
      'results' => [],
      'fluid_ingredients' => [{'fluid' => 'minecraft:water', 'amount' => 1000}],
      'fluid_results' => [{'id' => 'minecraft:lava', 'amount' => 500}]
    }
    validation = call_private(:validate_create_recipe, 'test_mixing', recipe, 'create:mixing')
    
    assert_equal true, validation[:valid]
  end

  def test_validate_create_mixing_invalid_no_schema
    recipe = {
      'type' => 'create:mixing'
    }
    validation = call_private(:validate_create_recipe, 'test_mixing', recipe, 'create:mixing')
    
    assert_equal false, validation[:valid]
    assert validation[:errors].any? { |err| err.include?('must have at least one') }
  end

  def test_validate_create_emptying_singular_format
    recipe = {
      'type' => 'create:emptying',
      'ingredient' => 'minecraft:bucket',
      'result' => {'item' => 'minecraft:glass_bottle'},
      'fluid_result' => {'amount' => 250, 'id' => 'minecraft:water'}
    }
    validation = call_private(:validate_create_recipe, 'test_emptying', recipe, 'create:emptying')
    
    assert_equal true, validation[:valid]
  end

  def test_validate_create_emptying_combined_schema
    recipe = {
      'type' => 'create:emptying',
      'ingredients' => [{'item' => 'minecraft:bucket'}],
      'results' => [{'item' => 'minecraft:glass_bottle'}],
      'fluid_ingredients' => [{'fluid' => 'minecraft:water', 'amount' => 1000}],
      'fluid_results' => []
    }
    validation = call_private(:validate_create_recipe, 'test_emptying', recipe, 'create:emptying')
    
    assert_equal true, validation[:valid]
  end

  def test_uses_new_create_schema_detection
    old_recipe = {
      'ingredients' => ['minecraft:sand'],
      'results' => [{'item' => 'minecraft:dirt'}]
    }
    assert_equal false, call_private(:uses_new_create_schema?, old_recipe)
    
    new_recipe = {
      'fluid_ingredients' => [{'fluid' => 'minecraft:water', 'amount' => 1000}],
      'fluid_results' => []
    }
    assert_equal true, call_private(:uses_new_create_schema?, new_recipe)
  end

  def test_normalize_create_fluid_inputs
    fluid_ingredients = [
      { 'type' => 'fluid_stack', 'amount' => 1000, 'fluid' => 'minecraft:water' }
    ]
    result = call_private(:normalize_create_fluid_inputs, fluid_ingredients)
    
    assert_equal 1, result.length
    assert_equal 'minecraft:water', result[0]['fluid']['id']
    assert_equal 1000, result[0]['fluid']['amount']
    assert_equal Hash.new, result[0]['fluid']['nbt']
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

  def test_normalize_fd_cutting_v1215
    recipe = load_fixture('fd_cutting_v1215.json')
    result = call_private(:normalize_fd_cutting, 'ginger', recipe)

    assert_equal 'farmersdelight:cutting', result['type']
    assert_equal 'c:tools/knives', result['tool']
    assert_instance_of Array, result['input']
    assert_equal 'ubesdelight:ginger', result['input'][0]['item']['id']
    assert_equal 1, result['input'][0]['item']['count']
    assert_instance_of Array, result['output']
    assert_equal 1, result['output'].length
    assert_equal 'ubesdelight:ginger_chop', result['output'][0]['item']['id']
    assert_equal 2, result['output'][0]['item']['count']
  end

  def test_fd_cutting_result_with_explicit_count
    recipe = load_fixture('fd_cutting_v1215.json')
    result = call_private(:normalize_fd_cutting, 'ginger', recipe)

    # Ensure explicit count in result is properly parsed
    output = result['output'][0]
    assert_equal 'ubesdelight:ginger_chop', output['item']['id']
    assert_equal 2, output['item']['count'], "Result with explicit count should be parsed correctly"
  end

  def test_fd_cutting_single_ingredient_parsing
    recipe = load_fixture('fd_cutting_v1215.json')
    result = call_private(:normalize_fd_cutting, 'ginger', recipe)

    # Ensure input with implicit count defaults to 1
    input = result['input'][0]
    assert_equal 'ubesdelight:ginger', input['item']['id']
    assert_equal 1, input['item']['count'], "Input without explicit count should default to 1"
  end

  def test_normalize_tool_with_string_tag_format
    tool = "#c:tools/knife"
    result = call_private(:normalize_tool, tool)
    
    assert_equal 'c:tools/knife', result, "String tag format should have # prefix removed"
  end

  def test_normalize_tool_with_string_item_format
    tool = "minecraft:diamond_sword"
    result = call_private(:normalize_tool, tool)
    
    assert_equal 'minecraft:diamond_sword', result
  end

  def test_normalize_tool_with_hash_tag_format
    tool = { 'tag' => 'c:tools/knives' }
    result = call_private(:normalize_tool, tool)
    
    assert_equal 'c:tools/knives', result
  end

  def test_normalize_tool_with_hash_item_format
    tool = { 'item' => 'minecraft:diamond_sword' }
    result = call_private(:normalize_tool, tool)
    
    assert_equal 'minecraft:diamond_sword', result
  end

  def test_fd_cutting_with_string_tool_tag
    recipe = {
      'type' => 'farmersdelight:cutting',
      'ingredients' => [
        'ubesdelight:wild_ginger'
      ],
      'result' => [
        { 'item' => { 'count' => 1, 'id' => 'ubesdelight:ginger' } }
      ],
      'tool' => '#c:tools/knife'
    }
    result = call_private(:normalize_fd_cutting, 'ginger_from_wild_ginger', recipe)
    
    assert_equal 'farmersdelight:cutting', result['type']
    assert_equal 'c:tools/knife', result['tool'], "String tag tool format should normalize correctly"
    assert_equal 'ubesdelight:wild_ginger', result['input'][0]['item']['id']
    assert_equal 'ubesdelight:ginger', result['output'][0]['item']['id']
  end

  # ========== SMITHING RECIPE TESTS ==========

  def test_normalize_smithing_v12111
    recipe = load_fixture('smithing_v12111.json')
    result = call_private(:normalize_smithing, 'rolling_pin_netherite', recipe)

    assert_equal 'minecraft:smithing_transform', result['type']
    assert result['addition']
    assert result['input']
    assert result['template']
    assert result['output']

    # Addition should be parsed from direct string (tag reference with #)
    assert_equal 'c:ingots/netherite', result['addition']['tag']['id']
    assert_equal 1, result['addition']['tag']['count']

    # Input (base) should be parsed from direct string (item)
    assert_equal 'ubesdelight:rolling_pin_diamond', result['input']['item']['id']
    assert_equal 1, result['input']['item']['count']

    # Template should be parsed from direct string (item)
    assert_equal 'minecraft:netherite_upgrade_smithing_template', result['template']['item']['id']
    assert_equal 1, result['template']['item']['count']

    # Output should be correct
    assert_equal 'ubesdelight:rolling_pin_netherite', result['output']['item']['id']
    assert_equal 1, result['output']['item']['count']
  end

  def test_smithing_addition_with_tag_prefix
    recipe = load_fixture('smithing_v12111.json')
    result = call_private(:normalize_smithing, 'rolling_pin_netherite', recipe)
    
    # Verify addition field correctly handles tag prefix removal
    addition_id = result['addition']['tag']['id']
    assert_equal 'c:ingots/netherite', addition_id
    refute addition_id.start_with?('#'), "Addition ID should not contain '#' prefix"
  end

  def test_smithing_base_item_parsing
    recipe = load_fixture('smithing_v12111.json')
    result = call_private(:normalize_smithing, 'rolling_pin_netherite', recipe)
    
    # Verify base (input) is correctly parsed
    assert_equal 'ubesdelight:rolling_pin_diamond', result['input']['item']['id']
    assert_equal 1, result['input']['item']['count']
  end

  def test_smithing_template_parsing
    recipe = load_fixture('smithing_v12111.json')
    result = call_private(:normalize_smithing, 'rolling_pin_netherite', recipe)
    
    # Verify template is correctly parsed
    assert_equal 'minecraft:netherite_upgrade_smithing_template', result['template']['item']['id']
    assert_equal 1, result['template']['item']['count']
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
