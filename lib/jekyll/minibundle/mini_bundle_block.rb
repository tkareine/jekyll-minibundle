require 'pathname'
require 'jekyll/minibundle/hashes'
require 'jekyll/minibundle/files'
require 'jekyll/minibundle/environment'
require 'jekyll/minibundle/asset_file_registry'
require 'jekyll/minibundle/asset_tag_markup'

module Jekyll::Minibundle
  class MiniBundleBlock < Liquid::Block
    def initialize(tag_name, type, _tokens)
      super
      @type = type.strip.downcase.to_sym
      raise ArgumentError, "Missing asset type for minibundle block; pass value such as 'css' or 'js' as the argument" if @type.empty?
    end

    def render(context)
      site = context.registers.fetch(:site)

      bundle_config = get_current_bundle_config(parse_contents(super), site)
      baseurl = bundle_config.fetch('baseurl')
      destination_baseurl = bundle_config.fetch('destination_baseurl')
      attributes = bundle_config.fetch('attributes')

      do_form_destination_baseurl = !destination_baseurl.empty?
      destination_dir_path = Pathname.new(File.dirname(bundle_config.fetch('destination_path'))) if do_form_destination_baseurl

      register_asset_files(site, bundle_config).map do |file|
        dst_path = Files.strip_dot_slash_from_path_start(file.destination_path_for_markup)

        url =
          if do_form_destination_baseurl
            destination_baseurl + Pathname.new(dst_path).relative_path_from(destination_dir_path).to_s
          elsif !baseurl.empty?
            File.join(baseurl, dst_path)
          else
            dst_path
          end

        AssetTagMarkup.make_markup(@type, url, attributes)
      end.join("\n")
    end

    def self.default_bundle_config
      {
        'source_dir'          => '_assets',
        'destination_path'    => 'assets/site',
        'baseurl'             => '',
        'destination_baseurl' => '',
        'assets'              => [],
        'attributes'          => {},
        'minifier_cmd'        => nil
      }
    end

    private

    def parse_contents(contents)
      raise ArgumentError, 'Missing configuration for minibundle block; pass configuration in YAML syntax' if contents =~ /\A\s+\z/
      structure = parse_structure(contents)
      raise ArgumentError, "Unsupported minibundle block contents type (#{structure.class}), only Hash is supported: #{contents}" unless structure.is_a?(Hash)
      structure
    end

    def parse_structure(contents)
      ::SafeYAML.load(contents)
    rescue => e
      raise ArgumentError, "Failed parsing minibundle block contents syntax as YAML: #{contents.strip.inspect}. Cause: #{e}"
    end

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
      baseurl = '' if baseurl.nil? || baseurl == '.'
      baseurl = '/' if destination_path.start_with?('/') && baseurl.empty?

      [Files.strip_dot_slash_from_path_start(baseurl), destination_path.sub(%r{\A/+}, '')]
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
