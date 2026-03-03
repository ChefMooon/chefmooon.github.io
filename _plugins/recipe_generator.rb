# TODO
# - Add icon locations to recipe data
# - Identify common ingredients and increment count

require 'set'

module Jekyll
    class RecipeGenerator < Generator
        safe true
        VALID_LOADERS = Set.new(['fabric', 'neoforge', 'forge']).freeze

        # Recipe validation schemas - defines required fields and their expected types
        RECIPE_SCHEMAS = {
            'minecraft:crafting_shaped' => {
                required_fields: ['pattern', 'key', 'result'],
                field_types: { 'pattern' => [Array], 'key' => [Hash], 'result' => [Hash, String] }
            },
            'minecraft:crafting_shapeless' => {
                required_fields: ['ingredients', 'result'],
                field_types: { 'ingredients' => [Array], 'result' => [Hash, String] }
            },
            'minecraft:smithing_transform' => {
                required_fields: ['addition', 'base', 'template', 'result'],
                field_types: { 'addition' => [Hash, String], 'base' => [Hash, String], 'template' => [Hash, String], 'result' => [Hash, String] }
            },
            'minecraft:smelting' => {
                required_fields: ['ingredient', 'result'],
                field_types: { 'ingredient' => [Hash, String], 'result' => [Hash, String] }
            },
            'minecraft:smoking' => {
                required_fields: ['ingredient', 'result'],
                field_types: { 'ingredient' => [Hash, String], 'result' => [Hash, String] }
            },
            'minecraft:campfire_cooking' => {
                required_fields: ['ingredient', 'result'],
                field_types: { 'ingredient' => [Hash, String], 'result' => [Hash, String] }
            },
            'ubesdelight:baking_mat' => {
                required_fields: ['tool', 'ingredients', 'processing_stages', 'result'],
                field_types: { 'tool' => [Hash, String], 'ingredients' => [Array], 'processing_stages' => [Array], 'result' => [Array] }
            },
            'farmersdelight:cutting' => {
                required_fields: ['tool', 'ingredients', 'result'],
                field_types: { 'tool' => [Hash, String], 'ingredients' => [Array], 'result' => [Array] }
            },
            'farmersdelight:cooking' => {
                required_fields: ['ingredients', 'result'],
                field_types: { 'ingredients' => [Array], 'result' => [Hash, String] }
            },
            'create:milling' => {
                required_fields: ['ingredients', 'results', 'processingTime'],
                field_types: { 'ingredients' => [Array], 'results' => [Array], 'processingTime' => [Integer, Float] }
            },
            'create:mixing' => {
                required_fields: ['ingredients', 'results'],
                field_types: { 'ingredients' => [Array], 'results' => [Array] }
            },
            'create:emptying' => {
                required_fields: ['ingredients', 'results'],
                field_types: { 'ingredients' => [Array], 'results' => [Array] }
            },
            'create:filling' => {
                required_fields: ['ingredients', 'results'],
                field_types: { 'ingredients' => [Array], 'results' => [Array] }
            }
        }.freeze

        def initialize(config = {})
            super(config)
            @recipe_types_by_page = {}
            @recipe_data_by_page = {}
            @total_recipes_by_page = {}
            @lang_data_by_page = {}
            @validation_errors = {}
            @tags_used_by_page = {}
            @missing_tag_definitions = {}
        end

        private

        def validate_recipe(recipe_key, recipe_data, recipe_type)
            # Validates recipe data against its schema
            # Returns: { valid: true } or { valid: false, errors: ['error1', 'error2'] }
            
            # Special handling for Create recipes that support dual schemas
            if ['create:mixing', 'create:emptying', 'create:filling'].include?(recipe_type)
                return validate_create_recipe(recipe_key, recipe_data, recipe_type)
            end
            
            schema = RECIPE_SCHEMAS[recipe_type]
            return { valid: true } unless schema  # Schema doesn't exist for this type, can't validate
            
            errors = []
            
            # Check required fields
            schema[:required_fields].each do |field|
                if recipe_data[field].nil?
                    errors << "missing required field '#{field}'"
                elsif schema[:field_types] && schema[:field_types][field]
                    expected_types = schema[:field_types][field]
                    actual_type = recipe_data[field].class
                    unless expected_types.include?(actual_type)
                        errors << "field '#{field}' is #{actual_type} but expected #{expected_types.map(&:to_s).join(' or ')}"
                    end
                end
            end
            
            if errors.any?
                { valid: false, errors: errors }
            else
                { valid: true }
            end
        end

        def validate_create_recipe(recipe_key, recipe_data, recipe_type)
            # Validates Create recipes supporting three schema formats:
            # 1. Singular format (old): ingredient, result, fluid_result
            # 2. Array format (old): ingredients, results
            # 3. Fluid-separated format (new): ingredients, fluid_ingredients, results, fluid_results
            errors = []
            
            # Check that type exists
            if recipe_data['type'].nil?
                errors << "missing required field 'type'"
                return { valid: false, errors: errors }
            end
            
            # Check for at least one input source
            has_singular_input = recipe_data['ingredient'].is_a?(String) || recipe_data['ingredient'].is_a?(Hash)
            has_array_input = recipe_data['ingredients'].is_a?(Array) && recipe_data['ingredients'].any?
            has_fluid_input = recipe_data['fluid_ingredients'].is_a?(Array) && recipe_data['fluid_ingredients'].any?
            has_any_input = has_singular_input || has_array_input || has_fluid_input
            
            # Check for at least one output source
            has_singular_output = recipe_data['result'].is_a?(Hash) || recipe_data['result'].is_a?(String)
            has_array_output = recipe_data['results'].is_a?(Array) && recipe_data['results'].any?
            has_fluid_output = recipe_data['fluid_result'].is_a?(Hash) || (recipe_data['fluid_results'].is_a?(Array) && recipe_data['fluid_results'].any?)
            has_any_output = has_singular_output || has_array_output || has_fluid_output
            
            unless has_any_input
                errors << "must have at least one input: 'ingredient' (singular), 'ingredients' (array), or 'fluid_ingredients' (array)"
            end
            
            unless has_any_output
                errors << "must have at least one output: 'result' (singular), 'results' (array), 'fluid_result', or 'fluid_results' (array)"
            end
            
            if errors.any?
                { valid: false, errors: errors }
            else
                { valid: true }
            end
        end

        def log_validation_error(recipe_key, recipe_type, page_key, validation_result)
            # Logs a validation error and tracks it
            error_msg = validation_result[:errors].join('; ')
            Jekyll.logger.warn "Recipe validation failed for '#{recipe_key}' (#{recipe_type}): #{error_msg}"
            
            @validation_errors[page_key] ||= []
            @validation_errors[page_key] << {
                recipe_key: recipe_key,
                type: recipe_type,
                errors: validation_result[:errors]
            }
        end

        def collect_tags_from_ingredient(ingredient, page_key)
            # Extracts a tag id from a normalized ingredient hash and records it
            return unless ingredient.is_a?(Hash) && ingredient['tag'].is_a?(Hash)

            tag_id = ingredient['tag']['id']
            return unless tag_id

            @tags_used_by_page[page_key] ||= Set.new
            @tags_used_by_page[page_key].add(tag_id)
        end

        def collect_tags_from_recipe(recipe, page_key)
            # Walks all ingredient fields of a normalized recipe and collects tag ids
            return unless recipe.is_a?(Hash)

            # input can be a single ingredient hash or an array
            inputs = recipe['input'].is_a?(Array) ? recipe['input'] : [recipe['input']]
            inputs.each { |ing| collect_tags_from_ingredient(ing, page_key) }

            # smithing-specific fields
            collect_tags_from_ingredient(recipe['addition'], page_key)
            collect_tags_from_ingredient(recipe['template'], page_key)

            # output can be a single hash or an array
            outputs = recipe['output'].is_a?(Array) ? recipe['output'] : [recipe['output']]
            outputs.each { |out| collect_tags_from_ingredient(out, page_key) }
        end

        def validate_tags(page_key, version_folder, mod_id, site)
            # Compares all tags collected in recipes against the version-specific tag definition file
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

        def normalize_recipe_data(key, recipe_data)
            return nil unless recipe_data['type']
    
            begin
                case recipe_data['type']
                when 'minecraft:crafting_shaped'
                    normalize_crafting_shaped(key, recipe_data)
                when 'minecraft:crafting_shapeless'
                    normalize_crafting_shapeless(key, recipe_data)
                when 'minecraft:smithing_transform'
                    normalize_smithing(key, recipe_data)
                when 'minecraft:smelting'
                    normalize_smelting(key, recipe_data)
                when 'minecraft:smoking'
                    normalize_smoking(key, recipe_data)
                when 'minecraft:campfire_cooking'
                    normalize_campfire_cooking(key, recipe_data)
                when 'ubesdelight:baking_mat'
                    normalize_ud_baking_mat(key, recipe_data)
                when 'farmersdelight:cutting'
                    normalize_fd_cutting(key, recipe_data)
                when 'farmersdelight:cooking'
                    normalize_fd_cooking(key, recipe_data)
                when 'create:milling'
                    normalize_create_milling(key, recipe_data)
                when 'create:mixing'
                    normalize_create_mixing(key, recipe_data)
                when 'create:emptying'
                    normalize_create_emptying(key, recipe_data)
                when 'create:filling'
                    normalize_create_filling(key, recipe_data)
                else
                    Jekyll.logger.warn "Unknown recipe type: #{recipe_data['type']}"
                    nil
                end
            rescue => e
                Jekyll.logger.error "Error normalizing recipe '#{key}' (#{recipe_data['type']}): #{e.class} - #{e.message}"
                nil
            end
        end

        def normalize_load_conditions(recipe_data)
            conditions_map = {
              'fabric:load_conditions' => 'fabric',
              'neoforge:conditions' => 'neoforge',
              'conditions' => 'forge'
            }
            
            key, type = conditions_map.find { |k, _| recipe_data[k] }
            recipe_data['condition_type'] = type if key
            recipe_data[key]
        end

        def extract_ingredient(recipe_data)
            # Handle single-input recipes (smelting, smoking, campfire_cooking)
            # Supports both old format (wrapped in 'ingredient') and new format (direct)
            return recipe_data['ingredient'] if recipe_data['ingredient']
            return recipe_data  # Fallback for direct ingredient format
        end

        def normalize_input(ingredient)
            # Safety: extract ingredient if wrapped in a recipe_data object
            if ingredient.is_a?(Hash) && ingredient['ingredient'] && !ingredient['item'] && !ingredient['tag'] && !ingredient['fluid']
                ingredient = ingredient['ingredient']
            end

            if ingredient.is_a?(String)
                # Direct item ID: "minecraft:furnace" or "#minecraft:logs"
                if ingredient.start_with?('#')
                    {
                        'tag' => {
                            'id' => ingredient[1..],
                            'count' => 1
                        }
                    }
                else
                    {
                        'item' => {
                            'id' => ingredient,
                            'count' => 1
                        }
                    }
                end
            elsif ingredient.is_a?(Hash)
                # Object format
                if ingredient['fluid']
                    {
                        'fluid' => {
                            'id' => ingredient['fluid'],
                            'amount' => ingredient['amount'] || 1,
                            'nbt' => ingredient['nbt'] || {}
                        }
                    }
                else
                    # Determine if it's item or tag
                    type = if ingredient['item']
                        ingredient['item'].start_with?('#') ? 'tag' : 'item'
                    elsif ingredient['tag']
                        'tag'
                    else
                        'item'  # Default fallback
                    end
                    
                    # Extract ID (remove # prefix if present)
                    id = if type == 'tag'
                        ingredient['item']&.sub(/^#/, '') || ingredient['tag']
                    else
                        ingredient['item']
                    end
                    
                    count = ingredient['count'] || 1

                    {
                        type => {
                            'id' => id,
                            'count' => count
                        }
                    }
                end
            else
                # Unexpected format - log and provide fallback
                Jekyll.logger.warn "Unexpected ingredient format: #{ingredient.class} - #{ingredient.inspect}"
                { 'item' => { 'id' => 'unknown', 'count' => 1 } }
            end
        end

        def count_key_occurrences(pattern)
            pattern.join('').chars.reject { |c| c == ' ' }.tally
          end

        def normalize_input_with_pattern(ingredient, key, pattern)
            if ingredient.is_a?(String)
                type = 'item'
                id = ingredient
            else
                data = ingredient['ingredient'] || ingredient
                type = data['item'] ? 'item' : 'tag'
                id = data[type]
            end
            count = count_key_occurrences(pattern)[key] || 1
          
            output = {
              type => {
                'id' => id,
                'count' => count
              }
            }
            
            output['key'] = key
            output
        end

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
                            'id' => id,
                            'count' => items.sum { |i| i['count'] || 1 }
                        }
                    }
                when 'fluid'
                    total_amount = items.sum { |i| i['amount'] || 1 }
                    {
                        'fluid' => {
                            'id' => id,
                            'amount' => total_amount,
                            'nbt' => items.first['nbt'] || {}
                        }
                    }
                end
            end
        end
        
        def normalize_processing_stages(stage)
            {
                'stage' => {
                    'id' => stage['item']
                }
            }
        end
        
        def normalize_output(result)
            output = if result['item']
                if result['item'].is_a?(Hash)
                    if result['item'].dig('item')
                        {
                            'item' => {
                                'id' => result['item']['item'],
                                'count' => result['item']['count'] || 1
                            }
                        }
                    elsif result['item'].dig('id')
                        {
                            'item' => {
                                'id' => result['item']['id'],
                                'count' => result['count'] || 1
                            }
                        }
                    end
                else
                    {
                        'item' => {
                            'id' => result['item'],
                            'count' => result['count'] || 1
                        }
                    }
                end
            elsif result['id']
                {
                    'item' => {
                        'id' => result['id'],
                        'count' => result['count'] || 1
                    }
                }
            elsif result['result']
                {
                    'item' => {
                        'id' => result['result'],
                        'count' => result['count'] || 1
                    }
                }
            elsif result.is_a?(String)
                {
                    'item' => {
                        'id' => result,
                        'count' => 1
                    }
                }
            end

            output['chance'] = result['chance'] if result['chance']
            output
        end

        def normalize_create_output(result)
            if result['amount']
                output = {
                    'fluid' => {
                        'id' => result['fluid'] || result['id'],
                        'amount' => result['amount'],
                        'nbt' => result['nbt'] || {}
                    }
                }
            else
                output = {
                    'item' => {
                        'id' => result['item'] || result['id'],
                        'count' => result['count'] || 1
                    }
                }
            end

            output['chance'] = result['chance'] if result['chance']
            output
        end

        def pattern_to_coordinates(pattern)
            coordinates = {}
            
            pattern.each_with_index do |row, y|
              row.each_char.with_index do |char, x|
                key = "#{x}_#{y}"
                coordinates[key] = char
              end
            end
            
            # Ensure all positions are present (0-2 for both x and y)
            (0..2).each do |y|
              (0..2).each do |x|
                key = "#{x}_#{y}"
                coordinates[key] = " " unless coordinates.key?(key)
              end
            end
            
            coordinates
          end

        def normalize_crafting_shaped(key, recipe_data) 
            {
                'filename' => key,
                'load_conditions' => normalize_load_conditions(recipe_data),
                'type' => recipe_data['type'],
                'category' => recipe_data['category'] || 'misc',
                'pattern' => pattern_to_coordinates(recipe_data['pattern']),
                'input' => recipe_data['key'].map { |key, value| normalize_input_with_pattern(value, key, recipe_data['pattern'])},
                'output' => normalize_output(recipe_data['result'])
            }
        end

        def normalize_crafting_shapeless(key, recipe_data)
            {
                'filename' => key,
                'load_conditions' => normalize_load_conditions(recipe_data),
                'type' => recipe_data['type'],
                'category' => recipe_data['category'] || 'misc',
                'input' => normalize_combined_input(recipe_data['ingredients']),
                'output' => normalize_output(recipe_data['result'])
            }
        end

        def normalize_smithing(key, recipe_data)
            # Handle both string format ("#tag:id" or "item:id") and object format ({"tag": "id"} or {"item": "id"})
            addition = normalize_smithing_input(recipe_data['addition'])
            template = normalize_smithing_input(recipe_data['template'])
            base = normalize_smithing_input(recipe_data['base'])
            
            {
                'filename' => key,
                'load_conditions' => normalize_load_conditions(recipe_data),
                'type' => recipe_data['type'],
                'addition' => addition,
                'template' => template,
                'input' => base,
                'output' => normalize_output(recipe_data['result'])
            }
        end

        def normalize_smithing_input(input_data)
            # Handles both string format and object format for smithing inputs
            # String format: "#tag:id" or "item:id"
            # Object format: {"tag": "id"} or {"item": "id"} or {"tag": {"id": "..."}} 
            
            return nil if input_data.nil?
            
            if input_data.is_a?(String)
                # Direct string format
                if input_data.start_with?('#')
                    # Tag format: "#tag:id" -> remove # prefix
                    {
                        'tag' => {
                            'id' => input_data[1..],
                            'count' => 1
                        }
                    }
                else
                    # Item format: "item:id"
                    {
                        'item' => {
                            'id' => input_data,
                            'count' => 1
                        }
                    }
                end
            elsif input_data.is_a?(Hash)
                # Object format - can have nested or flat structure
                if input_data['item']
                    item_val = input_data['item']
                    if item_val.is_a?(String)
                        # Flat structure: {"item": "id"}
                        if item_val.start_with?('#')
                            {
                                'tag' => {
                                    'id' => item_val[1..],
                                    'count' => input_data['count'] || 1
                                }
                            }
                        else
                            {
                                'item' => {
                                    'id' => item_val,
                                    'count' => input_data['count'] || 1
                                }
                            }
                        end
                    elsif item_val.is_a?(Hash)
                        # Nested structure: {"item": {"id": "..."}}
                        {
                            'item' => {
                                'id' => item_val['id'],
                                'count' => item_val['count'] || input_data['count'] || 1
                            }
                        }
                    end
                elsif input_data['tag']
                    tag_val = input_data['tag']
                    if tag_val.is_a?(String)
                        {
                            'tag' => {
                                'id' => tag_val,
                                'count' => input_data['count'] || 1
                            }
                        }
                    elsif tag_val.is_a?(Hash)
                        {
                            'tag' => {
                                'id' => tag_val['id'],
                                'count' => tag_val['count'] || input_data['count'] || 1
                            }
                        }
                    end
                end
            else
                nil
            end
        end
        
        def normalize_smelting(key, recipe_data)
            {
                'filename' => key,
                'load_conditions' => normalize_load_conditions(recipe_data),
                'type' => recipe_data['type'],
                'category' => recipe_data['category'] || 'misc',
                'cookingtime' => recipe_data['cookingtime'],
                'experience' => recipe_data['experience'],
                'input' => normalize_input(extract_ingredient(recipe_data)),
                'output' => normalize_output(recipe_data['result'])
            }
        end

        def normalize_smoking(key, recipe_data)
            {
                'filename' => key,
                'load_conditions' => normalize_load_conditions(recipe_data),
                'type' => recipe_data['type'],
                'category' => recipe_data['category'] || 'misc',
                'cookingtime' => recipe_data['cookingtime'],
                'experience' => recipe_data['experience'],
                'input' => normalize_input(extract_ingredient(recipe_data)),
                'output' => normalize_output(recipe_data['result'])
            }
        end

        def normalize_campfire_cooking(key, recipe_data)
            {
                'filename' => key,
                'load_conditions' => normalize_load_conditions(recipe_data),
                'type' => recipe_data['type'],
                'category' => recipe_data['category'] || 'misc',
                'cookingtime' => recipe_data['cookingtime'],
                'experience' => recipe_data['experience'],
                'input' => normalize_input(extract_ingredient(recipe_data)),
                'output' => normalize_output(recipe_data['result'])
            }
        end

        def normalize_ud_baking_mat(key, recipe_data)
            {
                'filename' => key,
                'load_conditions' => normalize_load_conditions(recipe_data),
                'type' => recipe_data['type'],
                'tool' => normalize_tool(recipe_data['tool']),
                'input' => normalize_combined_input(recipe_data['ingredients']),
                'processing_stages' => recipe_data['processing_stages'].map { |stage| normalize_processing_stages(stage)},
                'output' => recipe_data['result'].map { |result| normalize_output(result)}
            }
        end

        def normalize_fd_cutting(key, recipe_data)
            {
                'filename' => key,
                'load_conditions' => normalize_load_conditions(recipe_data),
                'type' => recipe_data['type'],
                'tool' => normalize_tool(recipe_data['tool']),
                'input' => recipe_data['ingredients'].map { |ingredient| normalize_input(ingredient)},
                'output' => recipe_data['result'].map { |result| normalize_output(result)}
            }
        end

        def normalize_fd_cooking(key, recipe_data)
            {
                'filename' => key,
                'load_conditions' => normalize_load_conditions(recipe_data),
                'type' => recipe_data['type'],
                'recipe_book_tab' => recipe_data['recipe_book_tab'] || 'misc',
                'experience' => recipe_data['experience'] || 0.0,
                'input' => normalize_combined_input(recipe_data['ingredients']),
                'output' => normalize_output(recipe_data['result'])
            }
        end

        def uses_new_create_schema?(recipe_data)
            # Detects if recipe uses new schema (fluid_ingredients/fluid_results)
            recipe_data['fluid_ingredients'].is_a?(Array) || recipe_data['fluid_results'].is_a?(Array)
        end

        def uses_singular_create_schema?(recipe_data)
            # Detects if recipe uses singular format (ingredient, result, fluid_result)
            !recipe_data['ingredient'].nil? || !recipe_data['result'].nil? || !recipe_data['fluid_result'].nil?
        end

        def normalize_singular_ingredient(ingredient)
            # Converts singular ingredient (string or hash) to array format for unified processing
            return [] if ingredient.nil?
            [ingredient]
        end

        def normalize_singular_result(result)
            # Converts singular result (string or hash) to array format for unified processing
            return [] if result.nil?
            [result]
        end

        def normalize_singular_fluid_result(fluid_result)
            # Converts singular fluid_result hash to array format for unified processing
            return [] if fluid_result.nil?
            [fluid_result]
        end

        def normalize_create_fluid_inputs(fluid_ingredients_list)
            # Converts new schema fluid_ingredients array into normalized input array
            return [] unless fluid_ingredients_list.is_a?(Array)
            
            fluid_ingredients_list.map do |fluid_ingredient|
                if fluid_ingredient.is_a?(Hash)
                    # Handle: {"type": "fluid_stack", "amount": 1000, "fluid": "minecraft:water"}
                    fluid_id = fluid_ingredient['fluid'] || fluid_ingredient['id']
                    amount = fluid_ingredient['amount'] || 1
                    
                    {
                        'fluid' => {
                            'id' => fluid_id,
                            'amount' => amount,
                            'nbt' => fluid_ingredient['nbt'] || {}
                        }
                    }
                else
                    fluid_ingredient
                end
            end
        end

        def normalize_create_milling(key, recipe_data)
            {
                'filename' => key,
                'load_conditions' => normalize_load_conditions(recipe_data),
                'type' => recipe_data['type'],
                'processing_time' => recipe_data['processingTime'],
                'input' => recipe_data['ingredients'].map { |ingredient| normalize_input(ingredient)},
                'output' => recipe_data['results'].map { |result| normalize_create_output(result)}
            }
        end

        def normalize_create_mixing(key, recipe_data)
            if uses_new_create_schema?(recipe_data)
                normalize_create_mixing_with_new_schema(key, recipe_data)
            else
                normalize_create_mixing_with_old_schema(key, recipe_data)
            end
        end

        def normalize_create_mixing_with_old_schema(key, recipe_data)
            is_singular = uses_singular_create_schema?(recipe_data)
            
            ingredients_array = if is_singular
                normalize_singular_ingredient(recipe_data['ingredient'])
            else
                recipe_data['ingredients'] || []
            end
            
            results_array = if is_singular
                normalize_singular_result(recipe_data['result'])
            else
                recipe_data['results'] || []
            end
            
            fluid_result_array = if is_singular
                normalize_singular_fluid_result(recipe_data['fluid_result'])
            else
                []
            end
            
            {
                'filename' => key,
                'load_conditions' => normalize_load_conditions(recipe_data),
                'type' => recipe_data['type'],
                'input' => normalize_combined_input(ingredients_array),
                'output' => (results_array.map { |result| normalize_create_output(result)} + (fluid_result_array.map { |result| normalize_create_output(result)}))
            }
        end

        def normalize_create_mixing_with_new_schema(key, recipe_data)
            is_singular = uses_singular_create_schema?(recipe_data)
            
            ingredients_array = if is_singular
                normalize_singular_ingredient(recipe_data['ingredient'])
            else
                recipe_data['ingredients'] || []
            end
            
            results_array = if is_singular
                normalize_singular_result(recipe_data['result'])
            else
                recipe_data['results'] || []
            end
            
            fluid_result_array = if is_singular
                normalize_singular_fluid_result(recipe_data['fluid_result'])
            else
                recipe_data['fluid_results'] || []
            end
            
            old_schema_inputs = normalize_combined_input(ingredients_array)
            new_schema_fluids = normalize_create_fluid_inputs(recipe_data['fluid_ingredients'])
            combined_inputs = old_schema_inputs + new_schema_fluids
            
            old_schema_outputs = results_array.map { |result| normalize_create_output(result)}
            new_schema_fluid_outputs = fluid_result_array.map { |result| normalize_create_output(result)}
            combined_outputs = old_schema_outputs + new_schema_fluid_outputs
            
            {
                'filename' => key,
                'load_conditions' => normalize_load_conditions(recipe_data),
                'type' => recipe_data['type'],
                'input' => combined_inputs,
                'output' => combined_outputs
            }
        end

        def normalize_create_emptying(key, recipe_data)
            if uses_new_create_schema?(recipe_data)
                normalize_create_emptying_with_new_schema(key, recipe_data)
            else
                normalize_create_emptying_with_old_schema(key, recipe_data)
            end
        end

        def normalize_create_emptying_with_old_schema(key, recipe_data)
            # Handle both old array format AND singular format
            is_singular = uses_singular_create_schema?(recipe_data)
            
            ingredients_array = if is_singular
                normalize_singular_ingredient(recipe_data['ingredient'])
            else
                recipe_data['ingredients'] || []
            end
            
            results_array = if is_singular
                normalize_singular_result(recipe_data['result'])
            else
                recipe_data['results'] || []
            end
            
            fluid_result_array = if is_singular
                normalize_singular_fluid_result(recipe_data['fluid_result'])
            else
                []
            end
            
            {
                'filename' => key,
                'load_conditions' => normalize_load_conditions(recipe_data),
                'type' => recipe_data['type'],
                'input' => (ingredients_array.map { |ingredient| normalize_input(ingredient)} + normalize_create_fluid_inputs(recipe_data['fluid_ingredients'] || [])),
                'output' => (results_array.map { |result| normalize_create_output(result)} + (fluid_result_array.map { |result| normalize_create_output(result)}))
            }
        end

        def normalize_create_emptying_with_new_schema(key, recipe_data)
            is_singular = uses_singular_create_schema?(recipe_data)
            
            ingredients_array = if is_singular
                normalize_singular_ingredient(recipe_data['ingredient'])
            else
                recipe_data['ingredients'] || []
            end
            
            results_array = if is_singular
                normalize_singular_result(recipe_data['result'])
            else
                recipe_data['results'] || []
            end
            
            fluid_result_array = if is_singular
                normalize_singular_fluid_result(recipe_data['fluid_result'])
            else
                recipe_data['fluid_results'] || []
            end
            
            old_schema_inputs = ingredients_array.map { |ingredient| normalize_input(ingredient)}
            new_schema_fluids = normalize_create_fluid_inputs(recipe_data['fluid_ingredients'])
            combined_inputs = old_schema_inputs + new_schema_fluids
            
            old_schema_outputs = results_array.map { |result| normalize_create_output(result)}
            new_schema_fluid_outputs = fluid_result_array.map { |result| normalize_create_output(result)}
            combined_outputs = old_schema_outputs + new_schema_fluid_outputs
            
            {
                'filename' => key,
                'load_conditions' => normalize_load_conditions(recipe_data),
                'type' => recipe_data['type'],
                'input' => combined_inputs,
                'output' => combined_outputs
            }
        end

        def normalize_create_filling(key, recipe_data)
            if uses_new_create_schema?(recipe_data)
                normalize_create_filling_with_new_schema(key, recipe_data)
            else
                normalize_create_filling_with_old_schema(key, recipe_data)
            end
        end

        def normalize_create_filling_with_old_schema(key, recipe_data)
            is_singular = uses_singular_create_schema?(recipe_data)
            
            ingredients_array = if is_singular
                normalize_singular_ingredient(recipe_data['ingredient'])
            else
                recipe_data['ingredients'] || []
            end
            
            results_array = if is_singular
                normalize_singular_result(recipe_data['result'])
            else
                recipe_data['results'] || []
            end
            
            fluid_result_array = if is_singular
                normalize_singular_fluid_result(recipe_data['fluid_result'])
            else
                []
            end
            
            {
                'filename' => key,
                'load_conditions' => normalize_load_conditions(recipe_data),
                'type' => recipe_data['type'],
                'input' => (ingredients_array.map { |ingredient| normalize_input(ingredient)} + normalize_create_fluid_inputs(recipe_data['fluid_ingredients'] || [])),
                'output' => (results_array.map { |result| normalize_create_output(result)} + (fluid_result_array.map { |result| normalize_create_output(result)}))
            }
        end

        def normalize_create_filling_with_new_schema(key, recipe_data)
            is_singular = uses_singular_create_schema?(recipe_data)
            
            ingredients_array = if is_singular
                normalize_singular_ingredient(recipe_data['ingredient'])
            else
                recipe_data['ingredients'] || []
            end
            
            results_array = if is_singular
                normalize_singular_result(recipe_data['result'])
            else
                recipe_data['results'] || []
            end
            
            fluid_result_array = if is_singular
                normalize_singular_fluid_result(recipe_data['fluid_result'])
            else
                recipe_data['fluid_results'] || []
            end
            
            old_schema_inputs = ingredients_array.map { |ingredient| normalize_input(ingredient)}
            new_schema_fluids = normalize_create_fluid_inputs(recipe_data['fluid_ingredients'])
            combined_inputs = old_schema_inputs + new_schema_fluids
            
            old_schema_outputs = results_array.map { |result| normalize_create_output(result)}
            new_schema_fluid_outputs = fluid_result_array.map { |result| normalize_create_output(result)}
            combined_outputs = old_schema_outputs + new_schema_fluid_outputs
            
            {
                'filename' => key,
                'load_conditions' => normalize_load_conditions(recipe_data),
                'type' => recipe_data['type'],
                'input' => combined_inputs,
                'output' => combined_outputs
            }
        end

        def normalize_tool(tool_data)
            # Handles both string and hash formats for tool field
            # String format: "#c:tools/knife" or "c:tools/knife"
            # Hash format: {"tag": "c:tools/knife"} or {"item": "c:tools/knife"}
            return nil if tool_data.nil?

            if tool_data.is_a?(String)
                # String format
                if tool_data.start_with?('#')
                    # Tag format: remove # prefix
                    tool_data[1..]
                else
                    # Item format
                    tool_data
                end
            elsif tool_data.is_a?(Hash)
                # Hash format - extract the value
                tool_data['item'] || tool_data['tag']
            else
                nil
            end
        end

        def loader_folder?(folder)
            return false if folder.nil? || !folder.is_a?(String)
            VALID_LOADERS.include?(folder.downcase)
        end

        def process_nested_recipes(recipe_list, page_key, current_loader = nil)
            recipe_list.each do |key, data|
                next unless data.is_a?(Hash)

                if data['type']
                    # Validate raw recipe data before normalization
                    validation = validate_recipe(key, data, data['type'])
                    unless validation[:valid]
                        log_validation_error(key, data['type'], page_key, validation)
                        next  # Skip this recipe
                    end

                    # Found a recipe file
                    normalized_data = normalize_recipe_data(key, data)
                    if normalized_data
                        # Validate normalized output has required structure
                        unless normalized_data['type'] && normalized_data['input'] && normalized_data['output']
                            error_msg = "normalized recipe missing required fields"
                            Jekyll.logger.warn "Recipe validation failed for '#{key}' (#{data['type']}): #{error_msg}"
                            @validation_errors[page_key] ||= []
                            @validation_errors[page_key] << {
                                recipe_key: key,
                                type: data['type'],
                                errors: [error_msg]
                            }
                            next  # Skip this recipe
                        end

                        normalized_data['loader'] = current_loader if current_loader
                        @recipe_data_by_page[page_key]&.add(normalized_data)
                        if current_loader
                            data['type'] = { 'value' => data['type'], 'loader' => current_loader }
                          else
                            data['type'] = data['type']
                          end
                        @recipe_types_by_page[page_key]&.add(data['type'])
                        @total_recipes_by_page[page_key] = (@total_recipes_by_page[page_key] || 0) + 1
                        collect_tags_from_recipe(normalized_data, page_key)
                    end
                elsif loader_folder?(key)
                    # Found a loader folder, recurse with loader info
                    process_nested_recipes(data, page_key, key)
                else
                    # Regular folder, recurse
                    process_nested_recipes(data, page_key, current_loader)
                end
            end
        end

        def process_item_lang_data(mod_id, key_info, data)
            {
                'type' => 'item',
                'key' => mod_id + ":" + key_info.last,
                'data' => data
            }
        end

        def process_block_lang_data(mod_id, key_info, data)
            {
                'type' => 'block',
                'key' => mod_id + ":" + key_info.last,
                'data' => data
            }
        end

        def process_lang_data(lang, page_key, mod_id)
            lang&.each do |folder, lang_data|
                lang_data.each do |key, data|
                    key_info = key.split(".")

                    # TODO: add support for tags and others if needed
                    # TODO: enchance add support for multiple locales
                    normalized_data = case key_info.first
                        when "item"  then process_item_lang_data(mod_id, key_info, data)
                        when "block" then process_block_lang_data(mod_id, key_info, data)
                        else nil
                    end

                    @lang_data_by_page[page_key]&.add(normalized_data) if normalized_data
                end
            end
        end

        def run_test(page_key, version_folder)
            if @recipe_data_by_page[page_key].nil? || @recipe_data_by_page[page_key].empty?
                Jekyll.logger.info "Recipe Test - #{page_key} - No recipes found to test."
                return
            end
            
            errors_found = false
            @recipe_data_by_page[page_key].each do |recipe|
                unless recipe['type'] && recipe['input'] && recipe['output']
                    Jekyll.logger.warn "Incomplete recipe data (#{version_folder}): #{recipe}"
                    errors_found = true
                end
        
                unless recipe['output']
                    recipe['output']&.each do |output|
                        unless output['item'] && output['item']['id'] && output['item']['id'].is_a?(String)
                            Jekyll.logger.warn "Incomplete recipe output data (#{version_folder}): #{recipe}"
                            errors_found = true
                        end
                    end
                end
            end
            unless errors_found
                Jekyll.logger.info "Recipe Test - #{page_key} - All recipes validated successfully."
            end
        end

        public
    
        def generate(site)
            page_data = site.pages.select { |page| page.data['layout'] == 'minecraft-mod/wiki/recipes'}

            page_data.each do |page_data|
                next unless page_data.data['minecraft_version'] && page_data.data['mod_id']
                
                mod_id = page_data.data['mod_id']
                version_folder = page_data.data['minecraft_version'].gsub(".", "-")
                all_recipes = site.data[mod_id]['recipes'][version_folder]

                begin
                    lang = site.data[mod_id]['lang'][version_folder]
                rescue NoMethodError, KeyError => e
                    Jekyll.logger.warn "Recipe Generator:", "Missing language folder '#{version_folder}' for mod '#{page_data.data['mod_id']}'."
                    lang = {}
                end

                page_key = "#{mod_id}_#{version_folder}"
                @recipe_types_by_page[page_key] = Set.new
                @recipe_data_by_page[page_key] = Set.new
                @total_recipes_by_page[page_key] = 0
                @lang_data_by_page[page_key] = Set.new
                @validation_errors[page_key] = []
                @tags_used_by_page[page_key] = Set.new
                @missing_tag_definitions[page_key] = []

                all_recipes&.each do |folder, recipe_list|
                    next unless recipe_list.is_a?(Hash)

                    if recipe_list['type']
                        # Single recipe file - validate before normalization
                        validation = validate_recipe(folder, recipe_list, recipe_list['type'])
                        unless validation[:valid]
                            log_validation_error(folder, recipe_list['type'], page_key, validation)
                            next
                        end

                        # Single recipe file
                        normalized_data = normalize_recipe_data(folder, recipe_list)
                        if normalized_data
                            # Validate normalized output
                            unless normalized_data['type'] && normalized_data['input'] && normalized_data['output']
                                error_msg = "normalized recipe missing required fields"
                                Jekyll.logger.warn "Recipe validation failed for '#{folder}' (#{recipe_list['type']}): #{error_msg}"
                                @validation_errors[page_key] << {
                                    recipe_key: folder,
                                    type: recipe_list['type'],
                                    errors: [error_msg]
                                }
                                next
                            end

                            @recipe_data_by_page[page_key].add(normalized_data)
                            @recipe_types_by_page[page_key].add(recipe_list['type'])
                            @total_recipes_by_page[page_key] += 1
                            collect_tags_from_recipe(normalized_data, page_key)
                        end
                    elsif loader_folder?(folder)
                        # Loader folder (fabric/forge/etc)
                        process_nested_recipes(recipe_list, page_key, folder)
                    else
                        # Regular folder with multiple recipes
                        process_nested_recipes(recipe_list, page_key, nil)
                    end
                rescue => e
                    Jekyll.logger.error "Error processing recipe folder '#{folder}': #{e.message}"
                end

                process_lang_data(lang, page_key, mod_id)

                page_data.data['recipes'] = @recipe_data_by_page[page_key].to_a
                page_data.data['recipe_types'] = @recipe_types_by_page[page_key].to_a
                page_data.data['total_recipes'] = @total_recipes_by_page[page_key]

                page_data.data['mod_lang'] = @lang_data_by_page[page_key].to_a if @lang_data_by_page[page_key].size > 0
                
                # Log validation summary for this page
                log_validation_summary(page_key, mod_id, version_folder)
                validate_tags(page_key, version_folder, mod_id, site)
                log_tag_validation_summary(page_key, mod_id, version_folder)
            end
        end

        def log_tag_validation_summary(page_key, mod_id, version_folder)
            missing = @missing_tag_definitions[page_key] || []
            return if missing.empty?

            Jekyll.logger.warn "Tag Validation Summary: #{missing.length} undefined tag(s) in [#{mod_id} v#{version_folder}]: #{missing.join(', ')}"
        end

        def log_validation_summary(page_key, mod_id, version_folder)
            # Logs a summary of all validation errors found for this page
            errors = @validation_errors[page_key] || []
            total_processed = @total_recipes_by_page[page_key] || 0
            
            return if errors.empty?

            # Group errors by recipe type
            errors_by_type = errors.group_by { |err| err[:type] }
            
            # Build summary message
            summary_parts = ["[#{mod_id} v#{version_folder}]"]
            errors_by_type.each do |type, type_errors|
                summary_parts << "#{type_errors.length} #{type}"
            end
            
            summary_msg = "Recipe Validation Summary: #{summary_parts.join(' | ')} (#{total_processed} processed successfully)"
            Jekyll.logger.warn summary_msg
        end
    end
end