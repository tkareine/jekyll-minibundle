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
      bundle_config = get_current_bundle_config(Compatibility.load_yaml(super), site)
      file = AssetFileRegistry.bundle_file(site, bundle_config)
      file.add_as_static_file_to(site)
      file.destination_path_for_markup
    end

    def self.default_bundle_config
      {
        'source_dir'       => '_assets',
        'destination_path' => 'assets/site',
        'assets'           => [],
        'attributes'       => {}
      }
    end

    private

    def get_current_bundle_config(local_bundle_config, site)
      MiniBundleBlock.default_bundle_config.
        merge(environment_bundle_config(site)).
        merge(local_bundle_config).
        merge('type' => @type)
    end

    def environment_bundle_config(site)
      { 'minifier_cmd' => Environment.minifier_command(site, @type) }
    end
  end
end

Liquid::Template.register_tag('minibundle', Jekyll::Minibundle::MiniBundleBlock)
