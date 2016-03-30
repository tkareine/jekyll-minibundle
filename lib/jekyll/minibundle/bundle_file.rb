require 'jekyll/minibundle/asset_bundle'
require 'jekyll/minibundle/asset_file_operations'
require 'jekyll/minibundle/asset_file_properties'
require 'jekyll/minibundle/asset_stamp'

module Jekyll::Minibundle
  class BundleFile
    include AssetFileOperations
    include AssetFileProperties

    attr_reader :stamped_at

    def initialize(site, config)
      @site = site
      @type = config.fetch('type')
      asset_source_dir = File.join(@site.source, config.fetch('source_dir'))
      @asset_paths = config.fetch('assets').map { |asset_path| File.join(asset_source_dir, "#{asset_path}.#{@type}") }
      @destination_path = config.fetch('destination_path')
      @minifier_cmd = config.fetch('minifier_cmd')
      @stamped_at = nil
      @is_modified = false
      @_asset_bundle = nil
    end

    def cleanup
      return unless @_asset_bundle
      @_asset_bundle.close
      @_asset_bundle = nil
    end

    def destination_path_for_markup
      # we must rebundle here, if at all, in order to make sure the
      # markup destination and generated file paths have the same
      # fingerprint
      if modified?
        @stamped_at = mtime
        @is_modified = true
        @_asset_stamp = nil
        asset_bundle.make_bundle
      end

      asset_destination_path
    end

    def path
      asset_bundle.path
    end

    def asset_destination_dir
      File.dirname(@destination_path)
    end

    def asset_destination_path
      "#{@destination_path}-#{asset_stamp}.#{@type}"
    end

    def extname
      ".#{@type}"
    end

    def modified_time
      @asset_paths.map { |f| File.stat(f).mtime }.max
    end

    # writes destination only after `destination_path_for_markup` has
    # been called
    def write(site_destination_dir)
      if @is_modified
        write_destination(site_destination_dir)
        @is_modified = false
        true
      else
        false
      end
    end

    private

    def asset_stamp
      @_asset_stamp ||= AssetStamp.from_file(path)
    end

    def asset_bundle
      @_asset_bundle ||= AssetBundle.new(
        type: @type,
        asset_paths: @asset_paths,
        site_dir: @site.source,
        minifier_cmd: @minifier_cmd
      )
    end
  end
end
