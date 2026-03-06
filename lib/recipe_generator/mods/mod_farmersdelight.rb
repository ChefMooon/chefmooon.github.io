module Jekyll
  class RecipeGenerator
    module Mods
      # Handles farmersdelight:* recipe types: cutting, cooking
      module FarmersDelight
        private

        def normalize_fd_cutting(recipe_key, recipe_data)
          {
            'filename'        => recipe_key,
            'load_conditions' => normalize_load_conditions(recipe_data),
            'type'            => recipe_data['type'],
            'tool'            => normalize_tool(recipe_data['tool']),
            'input'           => recipe_data['ingredients'].map { |ingredient| normalize_input(ingredient) },
            'output'          => recipe_data['result'].map { |result| normalize_output(result) }
          }
        end

        def normalize_fd_cooking(recipe_key, recipe_data)
          {
            'filename'         => recipe_key,
            'load_conditions'  => normalize_load_conditions(recipe_data),
            'type'             => recipe_data['type'],
            'recipe_book_tab'  => recipe_data['recipe_book_tab'] || 'misc',
            'experience'       => recipe_data['experience'] || 0.0,
            'input'            => normalize_combined_input(recipe_data['ingredients']),
            'output'           => normalize_output(recipe_data['result'])
          }
        end
      end
    end
  end
end

# Register Farmer's Delight recipe types
Jekyll::RecipeGenerator::SchemaRegistry.register(
  'farmersdelight:cutting',
  schema: {
    required_fields: ['tool', 'ingredients', 'result'],
    field_types: { 'tool' => [Hash, String], 'ingredients' => [Array], 'result' => [Array] }
  },
  normalize_method: :normalize_fd_cutting
)

Jekyll::RecipeGenerator::SchemaRegistry.register(
  'farmersdelight:cooking',
  schema: {
    required_fields: ['ingredients', 'result'],
    field_types: { 'ingredients' => [Array], 'result' => [Hash, String] }
  },
  normalize_method: :normalize_fd_cooking
)

