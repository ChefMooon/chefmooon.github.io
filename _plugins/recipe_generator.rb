# TODO
# - Add icon locations to recipe data
# - Identify common ingredients and increment count

require 'set'

module Jekyll
    class RecipeGenerator < Generator
        safe true
        VALID_LOADERS = Set.new(['fabric', 'neoforge', 'forge']).freeze

        def initialize(config = {})
            super(config)
            @recipe_types_by_page = {}
            @recipe_data_by_page = {}
            @total_recipes_by_page = {}
        end

        private

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
                else
                    Jekyll.logger.warn "Unknown recipe type: #{recipe_data['type']}"
                    nil
                end
            rescue => e
                Jekyll.logger.error "Error normalizing recipe for #{recipe_data}: #{e.message}"
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

        def normalize_input(ingredient)
            data = ingredient['ingredient'] || ingredient
            type = data['item'] ? 'item' : 'tag'
            id = data[type]
            count = data['count'] || 1

            {
                type => {
                'id' => id,
                'count' => count
                }
            }
        end

        def count_key_occurrences(pattern)
            pattern.join('').chars.reject { |c| c == ' ' }.tally
          end

        def normalize_input_with_pattern(ingredient, key, pattern)
            data = ingredient['ingredient'] || ingredient
            type = data['item'] ? 'item' : 'tag'
            id = data[type]
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
            grouped = ingredients.group_by do |ingredient|
              if ingredient['item']
                ['item', ingredient['item']]
              elsif ingredient['tag']
                ['tag', ingredient['tag']]
              end
            end
          
            grouped.map do |(type, id), items|
              {
                type => {
                  'id' => id,
                  'count' => items.length
                }
              }
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
            output = if result['result'] && result['result'].dig('id')
                {
                    'item' => {
                        'id' => result['result']['id'],
                        'count' => result['result']['count'] || 1
                    }
                }
            elsif result['item'] && result['item'].dig('id')
                {
                    'item' => {
                    'id' => result['item']['id'],
                    'count' => result['item']['count'] || 1
                    }
                }
            elsif result['item'] && result['item'].dig('item')
                {
                    'item' => {
                    'id' => result['item']['item'],
                    'count' => result['item']['count'] || 1
                    }
                }
            end

            output['chance'] = result['chance'] if result['chance']
            output
        end

        def normalize_create_output(result)
            output = {
                'item' => {
                    'id' => result['item'],
                    'count' => result['count'] || 1
                }
            }

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
                'output' => normalize_output(recipe_data)
            }
        end

        def normalize_crafting_shapeless(key, recipe_data)
            {
                'filename' => key,
                'load_conditions' => normalize_load_conditions(recipe_data),
                'type' => recipe_data['type'],
                'category' => recipe_data['category'] || 'misc',
                'input' => normalize_combined_input(recipe_data['ingredients']),
                'output' => normalize_output(recipe_data)
            }
        end

        def normalize_smithing(key, recipe_data)
            {
                'filename' => key,
                'load_conditions' => normalize_load_conditions(recipe_data),
                'type' => recipe_data['type'],
                'addition' => {
                    'item' => {
                        'id' => recipe_data['addition']['item'],
                        'count' =>  1
                    }
                },
                'template' => {
                    'item' => {
                        'id' => recipe_data['template']['item'],
                        'count' => 1
                    }
                },
                'input' => {
                    'item' => {
                        'id' => recipe_data['base']['item'],
                        'count' => recipe_data['base']['count'] || 1
                    }
                },
                'output' => normalize_output(recipe_data)
            }
        end
        
        def normalize_smelting(key, recipe_data)
            {
                'filename' => key,
                'load_conditions' => normalize_load_conditions(recipe_data),
                'type' => recipe_data['type'],
                'category' => recipe_data['category'] || 'misc',
                'cookingtime' => recipe_data['cookingtime'],
                'experience' => recipe_data['experience'],
                'input' => normalize_input(recipe_data),
                'output' => normalize_output(recipe_data)
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
                'input' => normalize_input(recipe_data),
                'output' => normalize_output(recipe_data)
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
                'input' => normalize_input(recipe_data),
                'output' => normalize_output(recipe_data)
            }
        end

        def normalize_ud_baking_mat(key, recipe_data)
            {
                'filename' => key,
                'load_conditions' => normalize_load_conditions(recipe_data),
                'type' => recipe_data['type'],
                'tool' => recipe_data['tool']['item'] || recipe_data['tool']['tag'],
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
                'tool' => recipe_data['tool']['item'] || recipe_data['tool']['tag'],
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
                'output' => normalize_output(recipe_data)
            }
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
            {
                'filename' => key,
                'load_conditions' => normalize_load_conditions(recipe_data),
                'type' => recipe_data['type'],
                'input' => recipe_data['ingredients'].map { |ingredient| normalize_input(ingredient)},
                'output' => recipe_data['results'].map { |result| normalize_create_output(result)}
            }
        end

        def loader_folder?(folder)
            return false if folder.nil? || !folder.is_a?(String)
            VALID_LOADERS.include?(folder.downcase)
        end

        def process_nested_recipes(recipe_list, page_key, current_loader = nil)
            recipe_list.each do |key, data|
                next unless data.is_a?(Hash)

                if data['type']
                    # Found a recipe file
                    normalized_data = normalize_recipe_data(key, data)
                    if normalized_data
                        normalized_data['loader'] = current_loader if current_loader
                        @recipe_data_by_page[page_key]&.add(normalized_data)
                        if current_loader
                            data['type'] = { 'value' => data['type'], 'loader' => current_loader }
                          else
                            data['type'] = data['type']
                          end
                        @recipe_types_by_page[page_key]&.add(data['type'])
                        @total_recipes_by_page[page_key] = (@total_recipes_by_page[page_key] || 0) + 1
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

        public
    
        def generate(site)
            page_data = site.pages.select { |page| page.data['layout'] == 'minecraft-mod/wiki/recipes'}

            page_data.each do |page_data|
                next unless page_data.data['minecraft_version'] && page_data.data['mod_id']
                
                version_folder = page_data.data['minecraft_version'].gsub(".", "-")
                all_recipes = site.data[page_data.data['mod_id']]['recipes'][version_folder]

                page_key = "#{page_data.data['mod_id']}_#{version_folder}"
                @recipe_types_by_page[page_key] = Set.new
                @recipe_data_by_page[page_key] = Set.new
                @total_recipes_by_page[page_key] = 0

                all_recipes&.each do |folder, recipe_list|
                    next unless recipe_list.is_a?(Hash)

                    if recipe_list['type']
                        # Single recipe file
                        @recipe_data_by_page[page_key].add(normalize_recipe_data(folder, recipe_list))
                        @recipe_types_by_page[page_key].add(recipe_list['type'])
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

                page_data.data['recipes'] = @recipe_data_by_page[page_key].to_a
                page_data.data['recipe_types'] = @recipe_types_by_page[page_key].to_a
                page_data.data['total_recipes'] = @total_recipes_by_page[page_key]

                # Jekyll.logger.info "Processed #{page_key} with #{@total_recipes_by_page[page_key]} recipes"
            end
        end
    end
end