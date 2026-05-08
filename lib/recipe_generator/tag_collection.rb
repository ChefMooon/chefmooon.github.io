require 'set'

module Jekyll
  class RecipeGenerator
    # Collects tag IDs referenced in normalized recipes and validates them against
    # the version-specific tag definition file in _data/tags/{version}.yml.
    module TagCollection
      private

      def add_tag_to_page(tag_id, page_key)
        return if tag_id.to_s.strip.empty?

        @tags_used_by_page[page_key] ||= Set.new
        @tags_used_by_page[page_key].add(tag_id)
      end

      def collect_tags_from_ingredient(ingredient, page_key)
        return unless ingredient.is_a?(Hash)

        tag_data = ingredient['tag']
        if tag_data.is_a?(Hash)
          add_tag_to_page(tag_data['id'], page_key)
        elsif tag_data.is_a?(String)
          add_tag_to_page(tag_data.sub(/^#/, ''), page_key)
        end

        # Choice-list ingredients are normalized as { 'choices' => [ ... ] }.
        # Recurse so nested tag alternatives are included in validation.
        choices = ingredient['choices']
        if choices.is_a?(Array)
          choices.each { |choice| collect_tags_from_ingredient(choice, page_key) }
        end
      end

      def collect_tags_from_recipe(recipe, page_key)
        return unless recipe.is_a?(Hash)

        inputs = recipe['input'].is_a?(Array) ? recipe['input'] : [recipe['input']]
        inputs.each { |ing| collect_tags_from_ingredient(ing, page_key) }

        # smithing-specific slots
        collect_tags_from_ingredient(recipe['addition'], page_key)
        collect_tags_from_ingredient(recipe['template'], page_key)

        outputs = recipe['output'].is_a?(Array) ? recipe['output'] : [recipe['output']]
        outputs.each { |out| collect_tags_from_ingredient(out, page_key) }
      end

      def validate_tags(page_key, version_folder, mod_id, site)
        tags_used = @tags_used_by_page[page_key] || Set.new
        return if tags_used.empty?

        tag_definitions = site.data.dig('tags', version_folder) || {}

        if tag_definitions.empty?
          Jekyll.logger.warn "Tag Validation: No tag definition file found for version '#{version_folder}' (#{mod_id}). Expected _data/tags/#{version_folder}.yml"
          return
        end

        missing = tags_used.reject { |tag| tag_definitions.key?(tag) }.sort

        @missing_tag_definitions[page_key] = missing

        missing.each do |tag|
          Jekyll.logger.warn "Missing tag definition '#{tag}' (#{mod_id} v#{version_folder})"
        end
      end

      public

      def log_tag_validation_summary(page_key, mod_id, version_folder)
        missing = @missing_tag_definitions[page_key] || []
        return if missing.empty?

        Jekyll.logger.warn "Tag Validation Summary: #{missing.length} undefined tag(s) in [#{mod_id} v#{version_folder}]: #{missing.join(', ')}"
      end
    end
  end
end
