require 'jekyll/minibundle/asset_file_registry'
require 'jekyll/minibundle/compatibility'
require 'jekyll/minibundle/environment'

module Jekyll::Minibundle
  class MiniBundleBlock < Liquid::Block
    def initialize(tag_name, type, _tokens)
      super
      @type = type.strip.downcase.to_sym
    end

    def render(context)
      site = context.registers.fetch(:site)
      config = get_current_config(Compatibility.load_yaml(super), site)
      file = AssetFileRegistry.bundle_file(site, config)
      file.add_as_static_file_to(site)
      file.destination_path_for_markup
    end

    def self.default_block_config
      {
        'source_dir'       => '_assets',
        'destination_path' => 'assets/site',
        'assets'           => [],
        'attributes'       => {}
      }
    end

    private

    def get_current_config(local_block_config, site)
      MiniBundleBlock.default_block_config.
        merge(environment_block_config(site)).
        merge(local_block_config).
        merge('type' => @type)
    end

    def environment_block_config(site)
      { 'minifier_cmd' => Environment.minifier_command(site, @type) }
    end
  end
end

Liquid::Template.register_tag('minibundle', Jekyll::Minibundle::MiniBundleBlock)
