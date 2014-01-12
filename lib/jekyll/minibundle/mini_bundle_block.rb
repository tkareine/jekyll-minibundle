require 'yaml'
require 'jekyll/minibundle/asset_file_registry'

module Jekyll::Minibundle
  class MiniBundleBlock < Liquid::Block
    def initialize(tag_name, type, _tokens)
      super
      @type = type.strip.to_sym
    end

    def render(context)
      site = context.registers[:site]
      config = get_current_config(YAML.load(super), site)
      file = AssetFileRegistry.bundle_file(config)
      file.static_file!(site)
      file.markup
    end

    def self.default_config
      {
        'source_dir'        => '_assets',
        'destination_path'  => 'assets/site',
        'assets'            => [],
        'attributes'        => {}
      }
    end

    private

    def get_current_config(user_config, site)
      MiniBundleBlock.default_config.
        merge(user_config).
        merge('type' => @type, 'site_dir' => site.source)
    end
  end
end

Liquid::Template.register_tag('minibundle', Jekyll::Minibundle::MiniBundleBlock)
