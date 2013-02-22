require 'jekyll/minibundle/asset_bundle'
require 'jekyll/minibundle/asset_file_operations'
require 'jekyll/minibundle/asset_stamp'
require 'jekyll/minibundle/asset_tag_markup'

module Jekyll::Minibundle
  class BundleFile
    include AssetFileOperations

    @@mtimes = {}
    @@writes_after_mtime_updates = Hash.new false

    def initialize(config)
      @type = config['type']
      @site_source_dir = config['site_dir']
      asset_source_dir = File.join @site_source_dir, config['source_dir']
      @assets = config['assets'].map { |asset_path| File.join asset_source_dir, "#{asset_path}.#{@type}" }
      @destination_path = config['destination_path']
      @attributes = config['attributes']
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
      rebundle_assets if modified?

      if File.exists?(destination(site_destination_dir)) && destination_written_after_mtime_update?
        false
      else
        write_destination site_destination_dir
        @@writes_after_mtime_updates[asset_destination_canonical_path] = true
        true
      end
    end

    def markup
      AssetTagMarkup.make_markup @type, asset_destination_path, @attributes
    end

    private

    def asset_destination_canonical_path
      "#{@destination_path}.#{@type}"
    end

    def asset_stamp
      @asset_stamp ||= AssetStamp.from_file path
    end

    def asset_bundle
      @asset_bundle ||= begin
        bundle = AssetBundle.new(@type, @assets, @site_source_dir).make_bundle
        update_mtime
        bundle
      end
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
