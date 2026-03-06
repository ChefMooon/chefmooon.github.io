require 'set'

module Jekyll
  class RecipeGenerator
    # Handles detection of mod loader conditions and loader folder names.
    module LoadConditions
      VALID_LOADERS = Set.new(['fabric', 'neoforge', 'forge']).freeze

      private

      def normalize_load_conditions(recipe_data)
        conditions_map = {
          'fabric:load_conditions' => 'fabric',
          'neoforge:conditions'    => 'neoforge',
          'conditions'             => 'forge'
        }

        key, type = conditions_map.find { |k, _| recipe_data[k] }
        recipe_data['condition_type'] = type if key
        recipe_data[key]
      end

      def loader_folder?(folder)
        return false if folder.nil? || !folder.is_a?(String)
        VALID_LOADERS.include?(folder.downcase)
      end
    end
  end
end
