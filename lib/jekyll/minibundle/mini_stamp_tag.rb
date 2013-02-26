require 'jekyll/minibundle/stamp_file'

module Jekyll::Minibundle
  class MiniStampTag < Liquid::Tag
    def initialize(tag_name, text, _tokens)
      super
      @asset_source, @asset_destination = text.split(/\s+/, 3)[0, 2]
    end

    def render(context)
      site = context.registers[:site]
      file = StampFile.new(File.join(site.source, @asset_source), @asset_destination, &get_basenamer)
      file.static_file! site
      file.markup
    end

    private

    def get_basenamer
      if Environment.development?
        ->(base, ext, _) { base + ext }
      else
        ->(base, ext, stamper) { "#{base}-#{stamper.call}#{ext}" }
      end
    end
  end
end

Liquid::Template.register_tag('ministamp', Jekyll::Minibundle::MiniStampTag)
