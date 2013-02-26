require 'jekyll/minibundle/asset_bundle'
require 'jekyll/minibundle/asset_file_operations'
require 'jekyll/minibundle/asset_stamp'
require 'jekyll/minibundle/asset_tag_markup'

module Jekyll::Minibundle
  class BundleFile
    include AssetFileOperations

    def self.clear_cache
      @@mtimes = {}
      @@writes_after_mtime_updates = Hash.new false
      @@asset_bundles = {}
    end

    clear_cache

    def initialize(config)
      @type = config['type']
      @site_source_dir = config['site_dir']
      asset_source_dir = File.join @site_source_dir, config['source_dir']
      @assets = config['assets'].map { |asset_path| File.join asset_source_dir, "#{asset_path}.#{@type}" }
      @destination_path = config['destination_path']
      @attributes = config['attributes']
    end

    def markup
      # we must rebundle here, if at all, in order to make sure the
      # markup and generated file have the same fingerprint
      rebundle_assets if modified?
      AssetTagMarkup.make_markup @type, asset_destination_path, @attributes
    end

    def path
      asset_bundle.path
    end

    def asset_destination_path
      "#{@destination_path}-#{asset_stamp}.#{@type}"
    end

    def destination(site_destination_dir)
      File.join site_destination_dir, asset_destination_path
    end

    def mtime
      @assets.map { |f| File.stat(f).mtime.to_i }.max
    end

    def modified?
      @@mtimes[asset_destination_canonical_path] != mtime
    end

    def destination_written_after_mtime_update?
      @@writes_after_mtime_updates[asset_destination_canonical_path]
    end

    def write(site_destination_dir)
      if File.exists?(destination(site_destination_dir)) && destination_written_after_mtime_update?
        false
      else
        write_destination site_destination_dir
        @@writes_after_mtime_updates[asset_destination_canonical_path] = true
        true
      end
    end

    private

    def asset_destination_canonical_path
      "#{@destination_path}.#{@type}"
    end

    def asset_stamp
      @asset_stamp ||= AssetStamp.from_file path
    end

    def asset_bundle
      @@asset_bundles[asset_destination_canonical_path] ||= AssetBundle.new(@type, @assets, @site_source_dir)
    end

    def rebundle_assets
      @asset_stamp = nil
      asset_bundle.make_bundle
      update_mtime
    end

    def update_mtime
      p = asset_destination_canonical_path
      @@mtimes[p] = mtime
      @@writes_after_mtime_updates[p] = false
    end
  end
end
