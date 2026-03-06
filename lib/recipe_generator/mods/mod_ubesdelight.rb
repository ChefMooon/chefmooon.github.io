module Jekyll
  class RecipeGenerator
    module Mods
      # Handles ubesdelight:* recipe types: baking_mat
      module UbesDelight
        private

        def normalize_processing_stages(stage)
          {
            'stage' => {
              'id' => stage['item']
            }
          }
        end

        def normalize_ud_baking_mat(recipe_key, recipe_data)
          {
            'filename'          => recipe_key,
            'load_conditions'   => normalize_load_conditions(recipe_data),
            'type'              => recipe_data['type'],
            'tool'              => normalize_tool(recipe_data['tool']),
            'input'             => normalize_combined_input(recipe_data['ingredients']),
            'processing_stages' => recipe_data['processing_stages'].map { |stage| normalize_processing_stages(stage) },
            'output'            => recipe_data['result'].map { |result| normalize_output(result) }
          }
        end
      end
    end
  end
end

# Register Ube's Delight recipe types
Jekyll::RecipeGenerator::SchemaRegistry.register(
  'ubesdelight:baking_mat',
  schema: {
    required_fields: ['tool', 'ingredients', 'processing_stages', 'result'],
    field_types: {
      'tool'              => [Hash, String],
      'ingredients'       => [Array],
      'processing_stages' => [Array],
      'result'            => [Array]
    }
  },
  normalize_method: :normalize_ud_baking_mat
)

