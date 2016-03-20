require 'jekyll/minibundle/asset_file_registry'
require 'jekyll/minibundle/asset_tag_markup'
require 'jekyll/minibundle/compatibility'
require 'jekyll/minibundle/environment'

module Jekyll::Minibundle
  class MiniBundleBlock < Liquid::Block
    def initialize(tag_name, type, _tokens)
      super
      @type = type.strip.downcase.to_sym
      if @type.empty?
        fail ArgumentError, "No asset type for minibundle block; pass value such as 'css' or 'js' as the argument"
      end
    end

    def render(context)
      site = context.registers.fetch(:site)
      bundle_config = get_current_bundle_config(Compatibility.load_yaml(super), site)
      file = AssetFileRegistry.bundle_file(site, bundle_config)
      file.add_as_static_file_to(site)
      file.destination_paths_for_markup.map do |path|
        AssetTagMarkup.make_markup(@type, bundle_config.fetch('baseurl'), path, bundle_config.fetch('attributes'))
      end.join("\n")
    end

    def self.default_bundle_config
      {
        'source_dir'       => '_assets',
        'destination_path' => 'assets/site',
        'baseurl'          => '',
        'assets'           => [],
        'attributes'       => {}
      }
    end

    private

    def get_current_bundle_config(local_bundle_config, site)
      config = MiniBundleBlock.default_bundle_config.
        merge(environment_bundle_config(site)).
        merge(local_bundle_config).
        merge('type' => @type)

      baseurl, destination_path = normalize_baseurl_and_destination_path(config.fetch('baseurl'), config.fetch('destination_path'))

      config.merge({'baseurl' => baseurl, 'destination_path' => destination_path})
    end

    def environment_bundle_config(site)
      { 'minifier_cmd' => Environment.minifier_command(site, @type) }
    end

    def normalize_baseurl_and_destination_path(baseurl, destination_path)
      unless destination_path.start_with?('/')
        return [baseurl, destination_path]
      end

      normalized_baseurl = baseurl.empty? ? '/' : baseurl
      normalized_destination_path = destination_path.sub(/\A\/+/, '')

      [normalized_baseurl, normalized_destination_path]
    end
  end
end

Liquid::Template.register_tag('minibundle', Jekyll::Minibundle::MiniBundleBlock)
