module Jekyll
  class RecipeGenerator
    module Mods
      # Handles differentdoors:* recipe types: slide_to_swing, swing_to_slide, waxed_copper
      module DifferentDoors
        private

        def normalize_swing_to_slide(recipe_key, recipe_data)
          {
            'filename'        => recipe_key,
            'load_conditions' => normalize_load_conditions(recipe_data),
            'type'            => recipe_data['type'],
            'category'        => recipe_data['category'],
            'group'           => recipe_data['group'],
            'input'           => normalize_combined_input(recipe_data['ingredients']),
            'output'          => normalize_output(recipe_data['result'])
          }
        end

        def normalize_slide_to_swing(recipe_key, recipe_data)
          {
            'filename'        => recipe_key,
            'load_conditions' => normalize_load_conditions(recipe_data),
            'type'            => recipe_data['type'],
            'category'        => recipe_data['category'],
            'group'           => recipe_data['group'],
            'input'           => normalize_combined_input(recipe_data['ingredients']),
            'output'          => normalize_output(recipe_data['result'])
          }
        end

        def normalize_waxed_copper(recipe_key, recipe_data)
          {
            'filename'        => recipe_key,
            'load_conditions' => normalize_load_conditions(recipe_data),
            'type'            => recipe_data['type'],
            'category'        => recipe_data['category'],
            'group'           => recipe_data['group'],
            'input'           => normalize_combined_input(recipe_data['ingredients']),
            'output'          => normalize_output(recipe_data['result'])
          }
        end
      end
    end
  end
end

# Register Different Doors recipe types
Jekyll::RecipeGenerator::SchemaRegistry.register(
  'differentdoors:swing_to_slide',
  schema: {
    required_fields: ['ingredients', 'result'],
    field_types: { 'ingredients' => [Array], 'result' => [Hash] }
  },
  normalize_method: :normalize_swing_to_slide
)

Jekyll::RecipeGenerator::SchemaRegistry.register(
  'differentdoors:slide_to_swing',
  schema: {
    required_fields: ['ingredients', 'result'],
    field_types: { 'ingredients' => [Array], 'result' => [Hash] }
  },
  normalize_method: :normalize_slide_to_swing
)

Jekyll::RecipeGenerator::SchemaRegistry.register(
  'differentdoors:waxed_copper',
  schema: {
    required_fields: ['ingredients', 'result'],
    field_types: { 'ingredients' => [Array], 'result' => [Hash] }
  },
  normalize_method: :normalize_waxed_copper
)
