require 'jekyll/minibundle/asset_bundle'
require 'jekyll/minibundle/asset_file_operations'
require 'jekyll/minibundle/asset_stamp'
require 'jekyll/minibundle/asset_tag_markup'

module Jekyll::Minibundle
  class BundleFile
    include AssetFileOperations

    def initialize(config)
      @type = config.fetch('type')
      @site_source_dir = config.fetch('site_dir')
      asset_source_dir = File.join(@site_source_dir, config.fetch('source_dir'))
      @assets = config.fetch('assets').map { |asset_path| File.join(asset_source_dir, "#{asset_path}.#{@type}") }
      @destination_path = config.fetch('destination_path')
      @attributes = config.fetch('attributes')
      @stamped_at = nil
      @is_modified = false
    end

    def markup
      # we must rebundle here, if at all, in order to make sure the
      # markup and generated file have the same fingerprint
      if modified?
        @stamped_at = mtime
        @is_modified = true
        @_asset_stamp = nil
        asset_bundle.make_bundle
      end

      AssetTagMarkup.make_markup(@type, asset_destination_path, @attributes)
    end

    def path
      asset_bundle.path
    end

    def asset_destination_path
      "#{@destination_path}-#{asset_stamp}.#{@type}"
    end

    def destination(site_destination_dir)
      File.join(site_destination_dir, asset_destination_path)
    end

    def mtime
      @assets.map { |f| File.stat(f).mtime.to_i }.max
    end

    def modified?
      @stamped_at != mtime
    end

    # writes destination only after `markup` has been called
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
      @_asset_bundle ||= AssetBundle.new(@type, @assets, @site_source_dir)
    end
  end
end
