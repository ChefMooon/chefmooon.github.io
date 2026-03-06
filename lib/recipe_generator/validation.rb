module Jekyll
  class RecipeGenerator
    # Recipe validation logic. Uses SchemaRegistry to look up schemas for non-Create types.
    # Create recipes use a flexible multi-schema validator since they support old/new/singular formats.
    module Validation
      private

      def validate_recipe(recipe_key, recipe_data, recipe_type)
        # Create recipes support multiple schema formats — delegate to specialized validator
        if ['create:mixing', 'create:emptying', 'create:filling', 'create:milling'].include?(recipe_type)
          return validate_create_recipe(recipe_key, recipe_data, recipe_type)
        end

        schema = SchemaRegistry.schema_for(recipe_type)
        return { valid: true } unless schema

        errors = []

        schema[:required_fields].each do |field|
          if recipe_data[field].nil?
            errors << "missing required field '#{field}'"
          elsif schema[:field_types] && schema[:field_types][field]
            expected_types = schema[:field_types][field]
            actual_type    = recipe_data[field].class
            unless expected_types.include?(actual_type)
              errors << "field '#{field}' is #{actual_type} but expected #{expected_types.map(&:to_s).join(' or ')}"
            end
          end
        end

        errors.any? ? { valid: false, errors: errors } : { valid: true }
      end

      def validate_create_recipe(recipe_key, recipe_data, recipe_type)
        errors = []

        if recipe_data['type'].nil?
          errors << "missing required field 'type'"
          return { valid: false, errors: errors }
        end

        if recipe_type == 'create:milling'
          has_singular_input  = recipe_data['ingredient'].is_a?(String) || recipe_data['ingredient'].is_a?(Hash)
          has_array_input     = recipe_data['ingredients'].is_a?(Array) && recipe_data['ingredients'].any?
          has_any_input       = has_singular_input || has_array_input
          has_processing_time = recipe_data['processingTime'].is_a?(Numeric) || recipe_data['processing_time'].is_a?(Numeric)
          has_results         = recipe_data['results'].is_a?(Array) && recipe_data['results'].any?

          unless has_any_input && has_processing_time && has_results
            errors << "must have input (ingredient or ingredients array), processing_time, and results"
            return { valid: false, errors: errors }
          end

          return { valid: true }
        end

        # mixing / emptying / filling
        has_singular_input = recipe_data['ingredient'].is_a?(String) || recipe_data['ingredient'].is_a?(Hash)
        has_array_input    = recipe_data['ingredients'].is_a?(Array) && recipe_data['ingredients'].any?
        has_fluid_input    = recipe_data['fluid_ingredients'].is_a?(Array) && recipe_data['fluid_ingredients'].any?
        has_any_input      = has_singular_input || has_array_input || has_fluid_input

        has_singular_output = recipe_data['result'].is_a?(Hash) || recipe_data['result'].is_a?(String)
        has_array_output    = recipe_data['results'].is_a?(Array) && recipe_data['results'].any?
        has_fluid_output    = recipe_data['fluid_result'].is_a?(Hash) || (recipe_data['fluid_results'].is_a?(Array) && recipe_data['fluid_results'].any?)
        has_any_output      = has_singular_output || has_array_output || has_fluid_output

        errors << "must have at least one input: 'ingredient' (singular), 'ingredients' (array), or 'fluid_ingredients' (array)" unless has_any_input
        errors << "must have at least one output: 'result' (singular), 'results' (array), 'fluid_result', or 'fluid_results' (array)" unless has_any_output

        errors.any? ? { valid: false, errors: errors } : { valid: true }
      end

      def log_validation_error(recipe_key, recipe_type, page_key, validation_result)
        error_msg = validation_result[:errors].join('; ')
        Jekyll.logger.warn "Recipe validation failed for '#{recipe_key}' (#{recipe_type}): #{error_msg}"

        @validation_errors[page_key] ||= []
        @validation_errors[page_key] << {
          recipe_key: recipe_key,
          type:       recipe_type,
          errors:     validation_result[:errors]
        }
      end

      public

      def log_validation_summary(page_key, mod_id, version_folder)
        errors          = @validation_errors[page_key] || []
        total_processed = @total_recipes_by_page[page_key] || 0

        return if errors.empty?

        errors_by_type = errors.group_by { |err| err[:type] }

        summary_parts = ["[#{mod_id} v#{version_folder}]"]
        errors_by_type.each do |type, type_errors|
          summary_parts << "#{type_errors.length} #{type}"
        end

        summary_msg = "Recipe Validation Summary: #{summary_parts.join(' | ')} (#{total_processed} processed successfully)"
        Jekyll.logger.warn summary_msg
      end
    end
  end
end
