require 'jekyll/minibundle/stamp_file'

module Jekyll::Minibundle
  class MiniStampTag < Liquid::Tag
    def initialize(tag_name, text, _tokens)
      super
      @source, @destination = text.split(/\s+/, 3)[0, 2]
    end

    def render(context)
      site = context.registers[:site]
      file = StampFile.new File.join(site.source, @source), @destination
      file.static_file! site
      file.asset_path
    end
  end
end

Liquid::Template.register_tag('ministamp', Jekyll::Minibundle::MiniStampTag)
