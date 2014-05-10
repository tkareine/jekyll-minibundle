require 'jekyll/minibundle/asset_file_registry'

module Jekyll::Minibundle
  class MiniStampTag < Liquid::Tag
    def initialize(tag_name, text, _tokens)
      super
      @asset_source, @asset_destination = text.split(/\s+/, 3)[0, 2]
    end

    def render(context)
      site = context.registers.fetch(:site)
      file = AssetFileRegistry.stamp_file(site, @asset_source, @asset_destination)
      file.add_as_static_file_to(site)
      file.destination_path_for_markup
    end
  end
end

Liquid::Template.register_tag('ministamp', Jekyll::Minibundle::MiniStampTag)
