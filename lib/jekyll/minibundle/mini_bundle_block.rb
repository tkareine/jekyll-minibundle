require 'jekyll/minibundle/hashes'
require 'jekyll/minibundle/environment'
require 'jekyll/minibundle/asset_file_registry'
require 'jekyll/minibundle/asset_tag_markup'

module Jekyll::Minibundle
  class MiniBundleBlock < Liquid::Block
    def initialize(tag_name, type, _tokens)
      super
      @type = type.strip.downcase.to_sym
      raise ArgumentError, "No asset type for minibundle block; pass value such as 'css' or 'js' as the argument" if @type.empty?
    end

    def render(context)
      site = context.registers.fetch(:site)
      bundle_config = get_current_bundle_config(::SafeYAML.load(super), site)
      baseurl = bundle_config.fetch('baseurl')
      attributes = bundle_config.fetch('attributes')

      register_asset_files(site, bundle_config).map do |file|
        AssetTagMarkup.make_markup(@type, baseurl, file.destination_path_for_markup, attributes)
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
      config =
        MiniBundleBlock
        .default_bundle_config
        .merge(environment_bundle_config(site))
        .merge(local_bundle_config)
        .merge('type' => @type)

      baseurl, destination_path = normalize_baseurl_and_destination_path(config.fetch('baseurl'), config.fetch('destination_path'))

      config.merge('baseurl' => baseurl, 'destination_path' => destination_path)
    end

    def environment_bundle_config(site)
      {'minifier_cmd' => Environment.minifier_command(site, @type)}
    end

    def normalize_baseurl_and_destination_path(baseurl, destination_path)
      baseurl = '' if baseurl.nil?

      unless destination_path.start_with?('/')
        return [baseurl, destination_path]
      end

      normalized_baseurl = baseurl.empty? ? '/' : baseurl
      normalized_destination_path = destination_path.sub(%r{\A/+}, '')

      [normalized_baseurl, normalized_destination_path]
    end

    def register_asset_files(site, bundle_config)
      registry_config = Hashes.pick(
        bundle_config,
        'type',
        'source_dir',
        'destination_path',
        'assets',
        'minifier_cmd'
      )

      if Environment.development?(site)
        AssetFileRegistry.register_development_file_collection(site, registry_config).files
      else
        [AssetFileRegistry.register_bundle_file(site, registry_config)]
      end
    end
  end
end

Liquid::Template.register_tag('minibundle', Jekyll::Minibundle::MiniBundleBlock)
