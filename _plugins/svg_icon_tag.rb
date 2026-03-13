module Jekyll
  class SvgIconTag < Liquid::Tag
    def initialize(tag_name, markup, tokens)
      super
      @markup = markup.strip
    end

    def render(context)
      # Resolve filename from a string literal ("bluesky.svg") or a variable (social.icon_svg)
      filename = if @markup =~ /^["'](.*?)["']$/
        $1
      else
        context[@markup].to_s
      end

      return '' if filename.nil? || filename.empty?

      site = context.registers[:site]
      svg_path = File.join(site.source, 'assets', 'img', 'social-icons', filename)
      return '' unless File.exist?(svg_path)

      svg_content = File.read(svg_path, encoding: 'utf-8')

      # Rebuild the opening svg tag, keeping only viewBox
      svg_content.sub!(/<svg[^>]*>/) do |match|
        viewbox = match[/viewBox="([^"]+)"/, 1]
        rebuilt = '<svg class="social-icon" aria-hidden="true"'
        rebuilt += " viewBox=\"#{viewbox}\"" if viewbox
        rebuilt += '>'
        rebuilt
      end

      # Override fill so the icon inherits color from the parent CSS
      svg_content.gsub!(/fill="#[0-9a-fA-F]+"/, 'fill="currentColor"')

      svg_content.strip
    end
  end
end

Liquid::Template.register_tag('svg_icon', Jekyll::SvgIconTag)
