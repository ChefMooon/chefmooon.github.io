module Jekyll
  class RecipeGenerator
    # Processes language (translation) YAML data for a mod version,
    # normalizing item and block entries into a unified structure for wiki pages.
    module LangProcessor
      private

      def process_item_lang_data(mod_id, key_info, data)
        {
          'type' => 'item',
          'key'  => mod_id + ':' + key_info.last,
          'data' => data
        }
      end

      def process_block_lang_data(mod_id, key_info, data)
        {
          'type' => 'block',
          'key'  => mod_id + ':' + key_info.last,
          'data' => data
        }
      end

      def process_lang_data(lang, page_key, mod_id)
        lang&.each do |_folder, lang_data|
          lang_data.each do |key, data|
            key_info = key.split('.')

            # TODO: add support for tags and others if needed
            # TODO: enhance to support multiple locales
            normalized_data = case key_info.first
              when 'item'  then process_item_lang_data(mod_id, key_info, data)
              when 'block' then process_block_lang_data(mod_id, key_info, data)
              else nil
            end

            @lang_data_by_page[page_key]&.add(normalized_data) if normalized_data
          end
        end
      end
    end
  end
end
