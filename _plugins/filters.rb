module Jekyll
    module CapitalizeAllFilter
      def capitalize_all(input)
        input.split(' ').map(&:capitalize).join(' ')
      end
    end
  end
  
  Liquid::Template.register_filter(Jekyll::CapitalizeAllFilter)