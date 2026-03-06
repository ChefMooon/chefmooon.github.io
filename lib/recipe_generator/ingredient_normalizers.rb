module Jekyll
  class RecipeGenerator
    # Shared ingredient/tool normalizers used across multiple mods.
    # Converts the many ingredient formats found in Minecraft recipe JSONs into a
    # unified { 'item'/'tag'/'fluid' => { 'id' => ..., 'count'/'amount' => ... } } structure.
    module IngredientNormalizers
      private

      # Extracts the ingredient from a single-input recipe.
      # Supports both the old 'ingredient' wrapper format and the new direct format.
      def extract_ingredient(recipe_data)
        return recipe_data['ingredient'] if recipe_data['ingredient']
        recipe_data
      end

      # Normalizes a single ingredient (string or hash) to the unified structure.
      def normalize_input(ingredient)
        # Unwrap if ingredient is nested inside an 'ingredient' key
        if ingredient.is_a?(Hash) && ingredient['ingredient'] && !ingredient['item'] && !ingredient['tag'] && !ingredient['fluid']
          ingredient = ingredient['ingredient']
        end

        if ingredient.is_a?(String)
          if ingredient.start_with?('#')
            { 'tag' => { 'id' => ingredient[1..], 'count' => 1 } }
          else
            { 'item' => { 'id' => ingredient, 'count' => 1 } }
          end
        elsif ingredient.is_a?(Hash)
          if ingredient['fluid']
            {
              'fluid' => {
                'id'     => ingredient['fluid'],
                'amount' => ingredient['amount'] || 1,
                'nbt'    => ingredient['nbt'] || {}
              }
            }
          else
            type = if ingredient['item']
              ingredient['item'].start_with?('#') ? 'tag' : 'item'
            elsif ingredient['tag']
              'tag'
            else
              'item'
            end

            id = if type == 'tag'
              ingredient['item']&.sub(/^#/, '') || ingredient['tag']
            else
              ingredient['item']
            end

            count = ingredient['count'] || 1
            { type => { 'id' => id, 'count' => count } }
          end
        else
          Jekyll.logger.warn "Unexpected ingredient format: #{ingredient.class} - #{ingredient.inspect}"
          { 'item' => { 'id' => 'unknown', 'count' => 1 } }
        end
      end

      # Normalizes an array of ingredients, grouping identical items/tags/fluids and
      # summing their counts/amounts. Used by shapeless crafting and FD cooking.
      def normalize_combined_input(ingredients)
        normalized = ingredients.map do |ingredient|
          if ingredient.is_a?(String)
            if ingredient.start_with?('#')
              { 'tag' => ingredient[1..], 'count' => 1 }
            else
              { 'item' => ingredient, 'count' => 1 }
            end
          elsif ingredient.is_a?(Hash)
            if ingredient['item'].is_a?(String) && ingredient['item'].start_with?('#')
              { 'tag' => ingredient['item'][1..], 'count' => ingredient['count'] || 1 }
            elsif ingredient['tag']
              { 'tag' => ingredient['tag'], 'count' => ingredient['count'] || 1 }
            elsif ingredient['item']
              { 'item' => ingredient['item'], 'count' => ingredient['count'] || 1 }
            elsif ingredient['fluid']
              ingredient
            elsif ingredient['ingredient']
              ingredient['ingredient']
            else
              ingredient
            end
          else
            ingredient
          end
        end

        grouped = normalized.group_by do |ingredient|
          if ingredient['item']
            ['item', ingredient['item']]
          elsif ingredient['tag']
            ['tag', ingredient['tag']]
          elsif ingredient['fluid']
            ['fluid', ingredient['fluid']]
          end
        end

        grouped.map do |(type, id), items|
          case type
          when 'item', 'tag'
            {
              type => {
                'id'    => id,
                'count' => items.sum { |i| i['count'] || 1 }
              }
            }
          when 'fluid'
            total_amount = items.sum { |i| i['amount'] || 1 }
            {
              'fluid' => {
                'id'     => id,
                'amount' => total_amount,
                'nbt'    => items.first['nbt'] || {}
              }
            }
          end
        end
      end

      # Normalizes smithing table input slots (addition, base, template).
      # Handles string, flat-hash, and nested-hash formats.
      def normalize_smithing_input(input_data)
        return nil if input_data.nil?

        if input_data.is_a?(String)
          if input_data.start_with?('#')
            { 'tag' => { 'id' => input_data[1..], 'count' => 1 } }
          else
            { 'item' => { 'id' => input_data, 'count' => 1 } }
          end
        elsif input_data.is_a?(Hash)
          if input_data['item']
            item_val = input_data['item']
            if item_val.is_a?(String)
              if item_val.start_with?('#')
                { 'tag' => { 'id' => item_val[1..], 'count' => input_data['count'] || 1 } }
              else
                { 'item' => { 'id' => item_val, 'count' => input_data['count'] || 1 } }
              end
            elsif item_val.is_a?(Hash)
              { 'item' => { 'id' => item_val['id'], 'count' => item_val['count'] || input_data['count'] || 1 } }
            end
          elsif input_data['tag']
            tag_val = input_data['tag']
            if tag_val.is_a?(String)
              { 'tag' => { 'id' => tag_val, 'count' => input_data['count'] || 1 } }
            elsif tag_val.is_a?(Hash)
              { 'tag' => { 'id' => tag_val['id'], 'count' => tag_val['count'] || input_data['count'] || 1 } }
            end
          end
        else
          nil
        end
      end

      # Normalizes the tool field used by FD cutting and ubes baking_mat.
      # Accepts both string format ("#tag:id" / "item:id") and hash format.
      def normalize_tool(tool_data)
        return nil if tool_data.nil?

        if tool_data.is_a?(String)
          tool_data.start_with?('#') ? tool_data[1..] : tool_data
        elsif tool_data.is_a?(Hash)
          tool_data['item'] || tool_data['tag']
        else
          nil
        end
      end
    end
  end
end
