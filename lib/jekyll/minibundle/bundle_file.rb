require 'jekyll/minibundle/asset_bundle'
require 'jekyll/minibundle/asset_file_operations'
require 'jekyll/minibundle/asset_file_properties'
require 'jekyll/minibundle/asset_stamp'

module Jekyll::Minibundle
  class BundleFile
    include AssetFileOperations
    include AssetFileProperties

    attr_reader :asset_destination_dir, :stamped_at

    def initialize(site, config)
      @site = site
      @type = config.fetch('type')
      asset_source_dir = File.join(@site.source, config.fetch('source_dir'))
      @asset_paths = config.fetch('assets').map { |asset_path| File.join(asset_source_dir, "#{asset_path}.#{@type}") }
      destination_path = config.fetch('destination_path')
      @asset_destination_dir = File.dirname(destination_path)
      @asset_destination_filename_prefix = File.basename(destination_path)
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
      # destination path in the markup and the generated file path
      # have the same fingerprint
      if modified?
        @stamped_at = mtime
        @is_modified = true
        @_asset_stamp = nil
        asset_bundle.make_bundle
      end

      asset_destination_path
    end

    def asset_source_path
      asset_bundle.path
    end

    def asset_destination_filename
      "#{@asset_destination_filename_prefix}-#{asset_stamp}#{extname}"
    end

    def extname
      ".#{@type}"
    end

    def modified_time
      @asset_paths.map { |f| File.stat(f).mtime }.max
    end

    # allows writing destination only after
    # `destination_path_for_markup` has been called
    def write(site_destination_dir)
      if @is_modified
        dst_path = write_destination(site_destination_dir)

        # respect user's umask; Ruby's tempfile has mode 0o600
        File.chmod(0o666 & ~File.umask, dst_path)

        @is_modified = false
        true
      else
        false
      end
    end

    private

    def asset_stamp
      @_asset_stamp ||= AssetStamp.from_file(asset_source_path)
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
