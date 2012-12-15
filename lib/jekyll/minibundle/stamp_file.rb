require 'jekyll/minibundle/asset_file_support'
require 'jekyll/minibundle/asset_stamp'

module Jekyll::Minibundle
  class StampFile
    include AssetFileSupport

    @@mtimes = Hash.new

    def initialize(asset_source_path, asset_destination_path)
      @asset_source_path = asset_source_path
      @asset_destination_dir = File.dirname asset_destination_path
      @asset_destination_extension = File.extname asset_destination_path
      @asset_destination_base_prefix = File.basename(asset_destination_path)[0 .. -(@asset_destination_extension.size + 1)]
      update_mtime
    end

    def path
      @asset_source_path
    end

    def asset_path
      File.join @asset_destination_dir, asset_destination_basename
    end

    def destination(site_destination_dir)
      File.join site_destination_dir, @asset_destination_dir, asset_destination_basename
    end

    def mtime
      File.stat(path).mtime.to_i
    end

    def modified?
      @@mtimes[path] != mtime
    end

    def write(site_destination_dir)
      clear_asset_stamp if modified?
      destination_path = destination site_destination_dir

      return false if File.exist?(destination_path) and !modified?

      update_mtime
      write_destination site_destination_dir

      true
    end

    private

    def asset_destination_basename
      "#{@asset_destination_base_prefix}-#{asset_stamp}#{@asset_destination_extension}"
    end

    def asset_stamp
      @asset_stamp ||= AssetStamp.from_file(path)
    end

    def clear_asset_stamp
      @asset_stamp = nil
    end

    def update_mtime
      @@mtimes[path] = mtime
    end
  end
end
