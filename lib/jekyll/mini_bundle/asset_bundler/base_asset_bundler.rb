# encoding: utf-8

require 'digest'
require 'fileutils'
require 'pathname'
require 'tempfile'

module Jekyll::MiniBundle::AssetBundler
  class BaseAssetBundler
    attr_reader :type
    attr_reader :site_config
    attr_reader :bundle_config

    def initialize(type, site_config, bundle_config)
      @type = type
      @site_config = site_config
      @bundle_config = bundle_config
    end

    def assets_src_dir
      @assets_src_root ||= Pathname.new(site_config['source']) + (bundle_config['src_dir'] || '_assets')
    end

    def assets_dst_dir
      @assets_dst_root ||= Pathname.new(site_config['destination']) + (bundle_config['dst_dir'] || 'assets')
    end
    
    def asset_paths
      bundle_config['assets'].map { |p| Pathname.new(assets_src_dir) + "#{p}.#{type}" }
    end

    def bundle_path(bundle_file)
      basename = bundle_config['bundle_name'] || 'bundle'
      digest = Digest::MD5.hexdigest File.read(bundle_file)
      bundle_filename = "#{basename}-#{digest}.#{type}"
      assets_dst_dir + bundle_filename
    end

    def css_markup_tag(path)
      # TODO: configuration for media="screen, projection"
      pp path
      bundle_href = path.relative_path_from assets_dst_dir
      %{<link href="#{bundle_href}" rel="stylesheet">}
    end
  end
end
