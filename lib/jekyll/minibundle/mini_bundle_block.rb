# encoding: utf-8

require 'yaml'
require 'jekyll/minibundle/asset_bundle'

module Jekyll::Minibundle
  class MiniBundleBlock < Liquid::Block
    def initialize(tag_name, type, _tokens)
      super
      @type = type.strip.to_sym
    end

    def render(context)
      site_config = context.registers[:site].config
      bundle_config = YAML.load super
      AssetBundle.for(@type, site_config, bundle_config).markup
    end
  end
end

Liquid::Template.register_tag('minibundle', Jekyll::Minibundle::MiniBundleBlock)
