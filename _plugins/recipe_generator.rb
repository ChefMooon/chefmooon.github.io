# TODO
# - Add icon locations to recipe data
# - Identify common ingredients and increment count

require 'set'

module Jekyll
    class RecipeGenerator < Generator
        safe true

        def initialize(config = {})
            super(config)
            @recipe_types_by_page = {}
            @recipe_data_by_page = {}
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
                else
                    Jekyll.logger.warn "Unknown recipe type: #{recipe_data['type']}"
                    nil
                end
            rescue => e
                Jekyll.logger.error "Error normalizing recipe for #{recipe_data}: #{e.message}"
                nil
            end
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
            output = if result['result']
                {
                    'item' => {
                        'id' => result['result']['id'],
                        'count' => result['result']['count'] || 1
                    }
                }
            elsif result['item']
                {
                    'item' => {
                        'id' => result['item']['id'],
                        'count' => result['item']['count'] || 1
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
                'type' => recipe_data['type'],
                'category' => recipe_data['category'] || 'misc',
                'input' => normalize_combined_input(recipe_data['ingredients']),
                'output' => normalize_output(recipe_data)
            }
        end

        def normalize_smithing(key, recipe_data)
            {
                'filename' => key,
                'type' => recipe_data['type'],
                'addition' => recipe_data['addition'],
                'template' => recipe_data['template'],
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
                'type' => recipe_data['type'],
                'tool' => recipe_data['tool']['item'] || recipe_data['tool']['tag'],
                'input' => recipe_data['ingredients'].map { |ingredient| normalize_input(ingredient)},
                'output' => recipe_data['result'].map { |result| normalize_output(result)}
            }
        end

        def normalize_fd_cooking(key, recipe_data)
            {
                'filename' => key,
                'type' => recipe_data['type'],
                'recipe_book_tab' => recipe_data['recipe_book_tab'] || 'misc',
                'experience' => recipe_data['experience'] || 0.0,
                'input' => normalize_combined_input(recipe_data['ingredients']),
                'output' => normalize_output(recipe_data)
            }
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

                all_recipes&.each do |folder, recipe_list|
                    next unless recipe_list.is_a?(Hash)
        
                    if recipe_list['type']
                        @recipe_data_by_page[page_key].add(normalize_recipe_data(folder, recipe_list))
                        @recipe_types_by_page[page_key].add(recipe_list['type'])
                    else
                        recipe_list.each do |filename, data|
                            next unless data.is_a?(Hash) && data['type']
                            @recipe_data_by_page[page_key].add(normalize_recipe_data(filename, data))
                            @recipe_types_by_page[page_key].add(data['type'])
                        end
                    end
                rescue => e
                    Jekyll.logger.error "Error processing recipe folder '#{folder}': #{e.message}"
                end

                page_data.data['recipes'] = @recipe_data_by_page[page_key].to_a
                page_data.data['recipe_types'] = @recipe_types_by_page[page_key].to_a
            end
        end
    end
end