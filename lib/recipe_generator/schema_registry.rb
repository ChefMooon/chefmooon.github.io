module Jekyll
  class RecipeGenerator
    # Central registry mapping recipe type strings to their schema and normalizer method.
    # Mod files call SchemaRegistry.register at load time to self-register their types.
    # The coordinator uses SchemaRegistry.lookup to dispatch normalization dynamically.
    module SchemaRegistry
      @registry = {}

      def self.register(recipe_type, schema:, normalize_method:)
        @registry[recipe_type] = { schema: schema, normalize_method: normalize_method }
      end

      def self.lookup(recipe_type)
        @registry[recipe_type]
      end

      def self.all_types
        @registry.keys
      end

      def self.schema_for(recipe_type)
        @registry.dig(recipe_type, :schema)
      end

      def self.normalize_method_for(recipe_type)
        @registry.dig(recipe_type, :normalize_method)
      end
    end
  end
end
