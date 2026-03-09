# frozen_string_literal: true

require "pathname"

module Jekyll
  # Loads modular wiki markdown content for versioned wiki home pages.
  class WikiModuleLoader < Generator
    safe true
    priority :low

    SUPPORTED_LAYOUTS = ["minecraft-mod/wiki/home"].freeze
    RESERVED_MODULE_FILES = ["home", "recipes", "item-details", "block-details", "translations-overview"].freeze
    DEFAULT_MODULE_ORDER = ["intro", "features", "effects", "mod_integrations", "development", "compatibility", "translation", "links"].freeze

    def generate(site)
      wiki_home_data = site.data.fetch("wiki_home", {})

      site.pages.each do |page|
        next unless SUPPORTED_LAYOUTS.include?(page.data["layout"])

        minecraft_version = page.data["minecraft_version"]
        next if minecraft_version.to_s.strip.empty?

        module_order = resolve_module_order(page, wiki_home_data)
        modules = load_modules(site, page, minecraft_version, module_order)

        page.data["wiki_modules"] = modules if modules.any?
      end
    end

    private

    def resolve_module_order(page, wiki_home_data)
      page_order = page.data["wiki_module_order"]
      return normalize_order(page_order) if page_order.is_a?(Array) && !page_order.empty?

      mod_id = page.data["mod_id"]
      data_order = wiki_home_data.dig(mod_id, "section_order")
      return normalize_order(data_order) if data_order.is_a?(Array) && !data_order.empty?

      discover_common_modules(page.site, page)
    end

    def normalize_order(order)
      order.map(&:to_s).reject(&:empty?)
    end

    def discover_common_modules(site, page)
      wiki_root = wiki_root_for_page(site, page)
      return [] unless Dir.exist?(wiki_root)

      discovered = Dir.glob(File.join(wiki_root, "*.md"))
                      .map { |path| File.basename(path, ".md") }
                      .reject { |name| RESERVED_MODULE_FILES.include?(name) }
                      .sort

      ordered = DEFAULT_MODULE_ORDER.select { |module_id| discovered.include?(module_id) }
      ordered + (discovered - ordered)
    end

    def load_modules(site, page, minecraft_version, module_order)
      module_order.filter_map do |module_id|
        module_path, is_override = find_module_path(site, page, minecraft_version, module_id)
        next if module_path.nil?

        rendered_content = render_module_content(site, page, module_path)
        next if rendered_content.nil? || rendered_content.strip.empty?

        {
          "id" => module_id,
          "path" => relative_path(site, module_path),
          "is_override" => is_override,
          "content" => rendered_content
        }
      end
    end

    def find_module_path(site, page, minecraft_version, module_id)
      base_path = wiki_root_for_page(site, page)
      version_override_path = File.join(base_path, minecraft_version, "#{module_id}.md")
      common_path = File.join(base_path, "#{module_id}.md")

      return [version_override_path, true] if File.file?(version_override_path)
      return [common_path, false] if File.file?(common_path)

      [nil, false]
    end

    def wiki_root_for_page(site, page)
      relative_path = page.path.to_s.sub(%r{^/}, "")
      page_file_path = File.join(site.source, relative_path)
      version_dir = File.dirname(page_file_path)
      File.expand_path("..", version_dir)
    end

    def render_module_content(site, page, module_path)
      raw_content = File.read(module_path)
      payload = site.site_payload.merge("page" => page.to_liquid)

      Liquid::Template
        .parse(raw_content, error_mode: :warn)
        .render!(payload, registers: { site: site, page: page }, strict_variables: false, strict_filters: false)
    rescue StandardError => e
      Jekyll.logger.warn("WikiModuleLoader:", "Failed to render #{relative_path(site, module_path)} (#{e.message})")
      raw_content
    end

    def relative_path(site, absolute_path)
      Pathname.new(absolute_path).relative_path_from(Pathname.new(site.source)).to_s
    rescue StandardError
      absolute_path
    end
  end
end
