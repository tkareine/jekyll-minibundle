require 'jekyll/minibundle/asset_stamp'

module Jekyll::Minibundle
  class MiniStampTag < Liquid::Tag
    def initialize(tag_name, _text, _tokens)
      super
      puts "tokens"
      pp _tokens
    end

    def render(context)
      AssetStamp.for "lol"
    end
  end
end

Liquid::Template.register_tag('ministamp', Jekyll::Minibundle::MiniStampTag)
