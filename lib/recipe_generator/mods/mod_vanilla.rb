module Jekyll
  class RecipeGenerator
    module Mods
      # Handles minecraft:* recipe types:
      #   crafting_shaped, crafting_shapeless, smithing_transform,
      #   smelting, smoking, campfire_cooking
      module Vanilla
        private

        def count_key_occurrences(pattern)
          pattern.join('').chars.reject { |c| c == ' ' }.tally
        end

        def normalize_input_with_pattern(ingredient, grid_key, pattern)
          if ingredient.is_a?(String)
            type = 'item'
            id   = ingredient
          else
            data = ingredient['ingredient'] || ingredient
            type = data['item'] ? 'item' : 'tag'
            id   = data[type]
          end

          count = count_key_occurrences(pattern)[grid_key] || 1

          output = {
            type => {
              'id'    => id,
              'count' => count
            }
          }
          output['key'] = grid_key
          output
        end

        def pattern_to_coordinates(pattern)
          coordinates = {}

          pattern.each_with_index do |row, y|
            row.each_char.with_index do |char, x|
              coordinates["#{x}_#{y}"] = char
            end
          end

          # Ensure all 3×3 positions are present
          (0..2).each do |y|
            (0..2).each do |x|
              key = "#{x}_#{y}"
              coordinates[key] = ' ' unless coordinates.key?(key)
            end
          end

          coordinates
        end

        def normalize_crafting_shaped(recipe_key, recipe_data)
          {
            'filename'        => recipe_key,
            'load_conditions' => normalize_load_conditions(recipe_data),
            'type'            => recipe_data['type'],
            'category'        => recipe_data['category'] || 'misc',
            'pattern'         => pattern_to_coordinates(recipe_data['pattern']),
            'input'           => recipe_data['key'].map { |grid_key, value| normalize_input_with_pattern(value, grid_key, recipe_data['pattern']) },
            'output'          => normalize_output(recipe_data['result'])
          }
        end

        def normalize_crafting_shapeless(recipe_key, recipe_data)
          {
            'filename'        => recipe_key,
            'load_conditions' => normalize_load_conditions(recipe_data),
            'type'            => recipe_data['type'],
            'category'        => recipe_data['category'] || 'misc',
            'input'           => normalize_combined_input(recipe_data['ingredients']),
            'output'          => normalize_output(recipe_data['result'])
          }
        end

        def normalize_smithing(recipe_key, recipe_data)
          addition = normalize_smithing_input(recipe_data['addition'])
          template = normalize_smithing_input(recipe_data['template'])
          base     = normalize_smithing_input(recipe_data['base'])

          {
            'filename'        => recipe_key,
            'load_conditions' => normalize_load_conditions(recipe_data),
            'type'            => recipe_data['type'],
            'addition'        => addition,
            'template'        => template,
            'input'           => base,
            'output'          => normalize_output(recipe_data['result'])
          }
        end

        def normalize_smelting(recipe_key, recipe_data)
          {
            'filename'        => recipe_key,
            'load_conditions' => normalize_load_conditions(recipe_data),
            'type'            => recipe_data['type'],
            'category'        => recipe_data['category'] || 'misc',
            'cookingtime'     => recipe_data['cookingtime'],
            'experience'      => recipe_data['experience'],
            'input'           => normalize_input(extract_ingredient(recipe_data)),
            'output'          => normalize_output(recipe_data['result'])
          }
        end

        def normalize_smoking(recipe_key, recipe_data)
          {
            'filename'        => recipe_key,
            'load_conditions' => normalize_load_conditions(recipe_data),
            'type'            => recipe_data['type'],
            'category'        => recipe_data['category'] || 'misc',
            'cookingtime'     => recipe_data['cookingtime'],
            'experience'      => recipe_data['experience'],
            'input'           => normalize_input(extract_ingredient(recipe_data)),
            'output'          => normalize_output(recipe_data['result'])
          }
        end

        def normalize_campfire_cooking(recipe_key, recipe_data)
          {
            'filename'        => recipe_key,
            'load_conditions' => normalize_load_conditions(recipe_data),
            'type'            => recipe_data['type'],
            'category'        => recipe_data['category'] || 'misc',
            'cookingtime'     => recipe_data['cookingtime'],
            'experience'      => recipe_data['experience'],
            'input'           => normalize_input(extract_ingredient(recipe_data)),
            'output'          => normalize_output(recipe_data['result'])
          }
        end
      end
    end
  end
end

# Register Vanilla recipe types
Jekyll::RecipeGenerator::SchemaRegistry.register(
  'minecraft:crafting_shaped',
  schema: {
    required_fields: ['pattern', 'key', 'result'],
    field_types: { 'pattern' => [Array], 'key' => [Hash], 'result' => [Hash, String] }
  },
  normalize_method: :normalize_crafting_shaped
)

Jekyll::RecipeGenerator::SchemaRegistry.register(
  'minecraft:crafting_shapeless',
  schema: {
    required_fields: ['ingredients', 'result'],
    field_types: { 'ingredients' => [Array], 'result' => [Hash, String] }
  },
  normalize_method: :normalize_crafting_shapeless
)

Jekyll::RecipeGenerator::SchemaRegistry.register(
  'minecraft:smithing_transform',
  schema: {
    required_fields: ['addition', 'base', 'template', 'result'],
    field_types: {
      'addition' => [Hash, String], 'base' => [Hash, String],
      'template' => [Hash, String], 'result' => [Hash, String]
    }
  },
  normalize_method: :normalize_smithing
)

Jekyll::RecipeGenerator::SchemaRegistry.register(
  'minecraft:smelting',
  schema: {
    required_fields: ['ingredient', 'result'],
    field_types: { 'ingredient' => [Hash, String], 'result' => [Hash, String] }
  },
  normalize_method: :normalize_smelting
)

Jekyll::RecipeGenerator::SchemaRegistry.register(
  'minecraft:smoking',
  schema: {
    required_fields: ['ingredient', 'result'],
    field_types: { 'ingredient' => [Hash, String], 'result' => [Hash, String] }
  },
  normalize_method: :normalize_smoking
)

Jekyll::RecipeGenerator::SchemaRegistry.register(
  'minecraft:campfire_cooking',
  schema: {
    required_fields: ['ingredient', 'result'],
    field_types: { 'ingredient' => [Hash, String], 'result' => [Hash, String] }
  },
  normalize_method: :normalize_campfire_cooking
)

