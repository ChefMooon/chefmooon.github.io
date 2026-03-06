# TODO
# - Add icon locations to recipe data
# - Identify common ingredients and increment count

require 'set'

# Load from lib/ directory to avoid Jekyll's plugin auto-loader scanning our module files
lib_dir = File.expand_path('../../lib/recipe_generator', __FILE__)
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

# Define the class stub first so sub-modules can safely open Jekyll::RecipeGenerator
module Jekyll
    class RecipeGenerator < Generator
        safe true
    end
end

# Load shared utilities
require 'schema_registry'
require 'load_conditions'
require 'ingredient_normalizers'
require 'output_normalizers'
require 'validation'
require 'tag_collection'
require 'lang_processor'

# Load mod-specific normalizers
require 'mods/mod_vanilla'
require 'mods/mod_farmersdelight'
require 'mods/mod_create'
require 'mods/mod_ubesdelight'

module Jekyll
    class RecipeGenerator
        include RecipeGenerator::LoadConditions
        include RecipeGenerator::IngredientNormalizers
        include RecipeGenerator::OutputNormalizers
        include RecipeGenerator::Validation
        include RecipeGenerator::TagCollection
        include RecipeGenerator::LangProcessor
        include RecipeGenerator::Mods::Vanilla
        include RecipeGenerator::Mods::FarmersDelight
        include RecipeGenerator::Mods::Create
        include RecipeGenerator::Mods::UbesDelight

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

        def normalize_recipe_data(key, recipe_data)
            return nil unless recipe_data['type']

            entry = SchemaRegistry.lookup(recipe_data['type'])
            unless entry
                Jekyll.logger.warn "Unknown recipe type: #{recipe_data['type']}"
                return nil
            end

            send(entry[:normalize_method], key, recipe_data)
        rescue => e
            Jekyll.logger.error "Error normalizing recipe '#{key}' (#{recipe_data['type']}): #{e.class} - #{e.message}"
            nil
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
    end
end