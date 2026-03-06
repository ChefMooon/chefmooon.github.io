module Jekyll
  class RecipeGenerator
    # Generic output normalizer shared by vanilla, Farmer's Delight, and Ube's Delight.
    # Create-specific output normalization lives in mod_create.rb.
    module OutputNormalizers
      private

      def normalize_output(result)
        output = if result['item']
          if result['item'].is_a?(Hash)
            if result['item'].dig('item')
              {
                'item' => {
                  'id'    => result['item']['item'],
                  'count' => result['item']['count'] || 1
                }
              }
            elsif result['item'].dig('id')
              {
                'item' => {
                  'id'    => result['item']['id'],
                  'count' => result['count'] || 1
                }
              }
            end
          else
            {
              'item' => {
                'id'    => result['item'],
                'count' => result['count'] || 1
              }
            }
          end
        elsif result['id']
          {
            'item' => {
              'id'    => result['id'],
              'count' => result['count'] || 1
            }
          }
        elsif result['result']
          {
            'item' => {
              'id'    => result['result'],
              'count' => result['count'] || 1
            }
          }
        elsif result.is_a?(String)
          {
            'item' => {
              'id'    => result,
              'count' => 1
            }
          }
        end

        output['chance'] = result['chance'] if result['chance']
        output
      end
    end
  end
end
