module Jekyll
  class RecipeGenerator
    module Mods
      # Handles create:* recipe types: milling, mixing, emptying, filling.
      #
      # Create recipes come in three schema variants that this module handles:
      #   old schema    — uses 'ingredients' array and 'results' array
      #   singular      — uses single 'ingredient', 'result', and/or 'fluid_result'
      #   new schema    — additionally uses 'fluid_ingredients' / 'fluid_results' arrays
      module Create
        private

        # ── Schema detection helpers ──────────────────────────────────────────

        def uses_new_create_schema?(recipe_data)
          recipe_data['fluid_ingredients'].is_a?(Array) || recipe_data['fluid_results'].is_a?(Array)
        end

        def uses_singular_create_schema?(recipe_data)
          !recipe_data['ingredient'].nil? || !recipe_data['result'].nil? || !recipe_data['fluid_result'].nil?
        end

        def uses_new_create_milling_schema?(recipe_data)
          recipe_data['ingredient'].is_a?(String) || recipe_data['ingredient'].is_a?(Hash)
        end

        # ── Singular-to-array coercers ────────────────────────────────────────

        def normalize_singular_ingredient(ingredient)
          return [] if ingredient.nil?
          [ingredient]
        end

        def normalize_singular_result(result)
          return [] if result.nil?
          [result]
        end

        def normalize_singular_fluid_result(fluid_result)
          return [] if fluid_result.nil?
          [fluid_result]
        end

        # ── Create-specific output normalizer ────────────────────────────────

        def normalize_create_output(result)
          if result['amount']
            output = {
              'fluid' => {
                'id'     => result['fluid'] || result['id'],
                'amount' => result['amount'],
                'nbt'    => result['nbt'] || {}
              }
            }
          else
            output = {
              'item' => {
                'id'    => result['item'] || result['id'],
                'count' => result['count'] || 1
              }
            }
          end

          output['chance'] = result['chance'] if result['chance']
          output
        end

        # Normalizes milling result entries, which may use the newer 'id' field.
        def normalize_milling_output(result)
          return { 'item' => { 'id' => result, 'count' => 1 } } if result.is_a?(String)
          return result if result.nil? || result.empty?

          output = {}

          if result['id']
            output['item'] = { 'id' => result['id'], 'count' => result['count'] || 1 }
          elsif result['item'] || result['tag'] || result['fluid']
            return normalize_create_output(result)
          end

          output['chance'] = result['chance'] if result['chance']
          output
        end

        # Converts a fluid_ingredients array (new schema) into the normalized input format.
        def normalize_create_fluid_inputs(fluid_ingredients_list)
          return [] unless fluid_ingredients_list.is_a?(Array)

          fluid_ingredients_list.map do |fluid_ingredient|
            if fluid_ingredient.is_a?(Hash)
              fluid_id = fluid_ingredient['fluid'] || fluid_ingredient['id']
              amount   = fluid_ingredient['amount'] || 1
              {
                'fluid' => {
                  'id'     => fluid_id,
                  'amount' => amount,
                  'nbt'    => fluid_ingredient['nbt'] || {}
                }
              }
            else
              fluid_ingredient
            end
          end
        end

        # ── Milling ───────────────────────────────────────────────────────────

        def normalize_create_milling(recipe_key, recipe_data)
          if uses_new_create_milling_schema?(recipe_data)
            normalize_create_milling_with_new_schema(recipe_key, recipe_data)
          else
            normalize_create_milling_with_old_schema(recipe_key, recipe_data)
          end
        end

        def normalize_create_milling_with_old_schema(recipe_key, recipe_data)
          {
            'filename'        => recipe_key,
            'load_conditions' => normalize_load_conditions(recipe_data),
            'type'            => recipe_data['type'],
            'processing_time' => recipe_data['processingTime'],
            'input'           => recipe_data['ingredients'].map { |ingredient| normalize_input(ingredient) },
            'output'          => recipe_data['results'].map { |result| normalize_create_output(result) }
          }
        end

        def normalize_create_milling_with_new_schema(recipe_key, recipe_data)
          ingredient_array = normalize_singular_ingredient(recipe_data['ingredient'])
          results_array    = recipe_data['results'] || []

          {
            'filename'        => recipe_key,
            'load_conditions' => normalize_load_conditions(recipe_data),
            'type'            => recipe_data['type'],
            'processing_time' => recipe_data['processing_time'],
            'input'           => ingredient_array.map { |ingredient| normalize_input(ingredient) },
            'output'          => results_array.map { |result| normalize_milling_output(result) }
          }
        end

        # ── Mixing ────────────────────────────────────────────────────────────
        # Mixing uses normalize_combined_input (groups + sums) for item ingredients.

        def normalize_create_mixing(recipe_key, recipe_data)
          if uses_new_create_schema?(recipe_data)
            normalize_create_mixing_with_new_schema(recipe_key, recipe_data)
          else
            normalize_create_mixing_with_old_schema(recipe_key, recipe_data)
          end
        end

        def normalize_create_mixing_with_old_schema(recipe_key, recipe_data)
          is_singular = uses_singular_create_schema?(recipe_data)

          ingredients_array  = is_singular ? normalize_singular_ingredient(recipe_data['ingredient']) : (recipe_data['ingredients'] || [])
          results_array      = is_singular ? normalize_singular_result(recipe_data['result'])         : (recipe_data['results'] || [])
          fluid_result_array = is_singular ? normalize_singular_fluid_result(recipe_data['fluid_result']) : []

          {
            'filename'        => recipe_key,
            'load_conditions' => normalize_load_conditions(recipe_data),
            'type'            => recipe_data['type'],
            'input'           => normalize_combined_input(ingredients_array),
            'output'          => results_array.map { |r| normalize_create_output(r) } +
                                 fluid_result_array.map { |r| normalize_create_output(r) }
          }
        end

        def normalize_create_mixing_with_new_schema(recipe_key, recipe_data)
          is_singular = uses_singular_create_schema?(recipe_data)

          ingredients_array  = is_singular ? normalize_singular_ingredient(recipe_data['ingredient']) : (recipe_data['ingredients'] || [])
          results_array      = is_singular ? normalize_singular_result(recipe_data['result'])         : (recipe_data['results'] || [])
          fluid_result_array = is_singular ? normalize_singular_fluid_result(recipe_data['fluid_result']) : (recipe_data['fluid_results'] || [])

          combined_inputs  = normalize_combined_input(ingredients_array) + normalize_create_fluid_inputs(recipe_data['fluid_ingredients'])
          combined_outputs = results_array.map { |r| normalize_create_output(r) } +
                             fluid_result_array.map { |r| normalize_create_output(r) }

          {
            'filename'        => recipe_key,
            'load_conditions' => normalize_load_conditions(recipe_data),
            'type'            => recipe_data['type'],
            'input'           => combined_inputs,
            'output'          => combined_outputs
          }
        end

        # ── Emptying ──────────────────────────────────────────────────────────
        # Emptying uses per-element normalize_input (preserves individual fluid items).

        def normalize_create_emptying(recipe_key, recipe_data)
          if uses_new_create_schema?(recipe_data)
            normalize_create_emptying_with_new_schema(recipe_key, recipe_data)
          else
            normalize_create_emptying_with_old_schema(recipe_key, recipe_data)
          end
        end

        def normalize_create_emptying_with_old_schema(recipe_key, recipe_data)
          is_singular = uses_singular_create_schema?(recipe_data)

          ingredients_array  = is_singular ? normalize_singular_ingredient(recipe_data['ingredient']) : (recipe_data['ingredients'] || [])
          results_array      = is_singular ? normalize_singular_result(recipe_data['result'])         : (recipe_data['results'] || [])
          fluid_result_array = is_singular ? normalize_singular_fluid_result(recipe_data['fluid_result']) : []

          {
            'filename'        => recipe_key,
            'load_conditions' => normalize_load_conditions(recipe_data),
            'type'            => recipe_data['type'],
            'input'           => ingredients_array.map { |i| normalize_input(i) } +
                                 normalize_create_fluid_inputs(recipe_data['fluid_ingredients'] || []),
            'output'          => results_array.map { |r| normalize_create_output(r) } +
                                 fluid_result_array.map { |r| normalize_create_output(r) }
          }
        end

        def normalize_create_emptying_with_new_schema(recipe_key, recipe_data)
          is_singular = uses_singular_create_schema?(recipe_data)

          ingredients_array  = is_singular ? normalize_singular_ingredient(recipe_data['ingredient']) : (recipe_data['ingredients'] || [])
          results_array      = is_singular ? normalize_singular_result(recipe_data['result'])         : (recipe_data['results'] || [])
          fluid_result_array = is_singular ? normalize_singular_fluid_result(recipe_data['fluid_result']) : (recipe_data['fluid_results'] || [])

          combined_inputs  = ingredients_array.map { |i| normalize_input(i) } +
                             normalize_create_fluid_inputs(recipe_data['fluid_ingredients'])
          combined_outputs = results_array.map { |r| normalize_create_output(r) } +
                             fluid_result_array.map { |r| normalize_create_output(r) }

          {
            'filename'        => recipe_key,
            'load_conditions' => normalize_load_conditions(recipe_data),
            'type'            => recipe_data['type'],
            'input'           => combined_inputs,
            'output'          => combined_outputs
          }
        end

        # ── Filling ───────────────────────────────────────────────────────────
        # Filling is identical to emptying in input/output handling.

        def normalize_create_filling(recipe_key, recipe_data)
          if uses_new_create_schema?(recipe_data)
            normalize_create_filling_with_new_schema(recipe_key, recipe_data)
          else
            normalize_create_filling_with_old_schema(recipe_key, recipe_data)
          end
        end

        def normalize_create_filling_with_old_schema(recipe_key, recipe_data)
          is_singular = uses_singular_create_schema?(recipe_data)

          ingredients_array  = is_singular ? normalize_singular_ingredient(recipe_data['ingredient']) : (recipe_data['ingredients'] || [])
          results_array      = is_singular ? normalize_singular_result(recipe_data['result'])         : (recipe_data['results'] || [])
          fluid_result_array = is_singular ? normalize_singular_fluid_result(recipe_data['fluid_result']) : []

          {
            'filename'        => recipe_key,
            'load_conditions' => normalize_load_conditions(recipe_data),
            'type'            => recipe_data['type'],
            'input'           => ingredients_array.map { |i| normalize_input(i) } +
                                 normalize_create_fluid_inputs(recipe_data['fluid_ingredients'] || []),
            'output'          => results_array.map { |r| normalize_create_output(r) } +
                                 fluid_result_array.map { |r| normalize_create_output(r) }
          }
        end

        def normalize_create_filling_with_new_schema(recipe_key, recipe_data)
          is_singular = uses_singular_create_schema?(recipe_data)

          ingredients_array  = is_singular ? normalize_singular_ingredient(recipe_data['ingredient']) : (recipe_data['ingredients'] || [])
          results_array      = is_singular ? normalize_singular_result(recipe_data['result'])         : (recipe_data['results'] || [])
          fluid_result_array = is_singular ? normalize_singular_fluid_result(recipe_data['fluid_result']) : (recipe_data['fluid_results'] || [])

          combined_inputs  = ingredients_array.map { |i| normalize_input(i) } +
                             normalize_create_fluid_inputs(recipe_data['fluid_ingredients'])
          combined_outputs = results_array.map { |r| normalize_create_output(r) } +
                             fluid_result_array.map { |r| normalize_create_output(r) }

          {
            'filename'        => recipe_key,
            'load_conditions' => normalize_load_conditions(recipe_data),
            'type'            => recipe_data['type'],
            'input'           => combined_inputs,
            'output'          => combined_outputs
          }
        end
      end
    end
  end
end

# Register Create recipe types (custom validator — schema: nil)
Jekyll::RecipeGenerator::SchemaRegistry.register(
  'create:milling',
  schema: nil,
  normalize_method: :normalize_create_milling
)

Jekyll::RecipeGenerator::SchemaRegistry.register(
  'create:mixing',
  schema: nil,
  normalize_method: :normalize_create_mixing
)

Jekyll::RecipeGenerator::SchemaRegistry.register(
  'create:emptying',
  schema: nil,
  normalize_method: :normalize_create_emptying
)

Jekyll::RecipeGenerator::SchemaRegistry.register(
  'create:filling',
  schema: nil,
  normalize_method: :normalize_create_filling
)

