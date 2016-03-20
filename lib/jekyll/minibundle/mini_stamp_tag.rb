require 'jekyll/minibundle/asset_file_registry'

module Jekyll::Minibundle
  class MiniStampTag < Liquid::Tag
    def initialize(tag_name, text, _tokens)
      super

      @source_path, destination_path = text.split(/\s+/, 3)[0, 2]

      if !@source_path || @source_path.empty?
        fail ArgumentError, "No asset source for ministamp tag; pass value such as '_assets/site.css' as the first argument"
      end

      if !destination_path || destination_path.empty?
        fail ArgumentError, "No asset destination for ministamp tag; pass value such as 'assets/site.css' as the second argument"
      end

      @baseurl, @destination_path = normalize_destination_path(destination_path)
    end

    def render(context)
      site = context.registers.fetch(:site)
      file = AssetFileRegistry.stamp_file(site, @source_path, @destination_path)
      file.add_as_static_file_to(site)
      @baseurl + file.destination_path_for_markup
    end

    private

    def normalize_destination_path(destination_path)
      if destination_path.start_with?('/')
        ['/', destination_path.sub(/\A\/+/, '')]
      else
        ['', destination_path]
      end
    end
  end
end

Liquid::Template.register_tag('ministamp', Jekyll::Minibundle::MiniStampTag)
