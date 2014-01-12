require 'jekyll/minibundle/asset_file_registry'

module Jekyll::Minibundle
  class MiniStampTag < Liquid::Tag
    def initialize(tag_name, text, _tokens)
      super
      @asset_source, @asset_destination = text.split(/\s+/, 3)[0, 2]
    end

    def render(context)
      site = context.registers[:site]
      file = AssetFileRegistry.stamp_file(File.join(site.source, @asset_source), @asset_destination)
      file.static_file!(site)
      file.markup
    end
  end
end

Liquid::Template.register_tag('ministamp', Jekyll::Minibundle::MiniStampTag)
