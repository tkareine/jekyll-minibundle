require 'jekyll/minibundle/asset_file_operations'
require 'jekyll/minibundle/asset_file_paths'
require 'jekyll/minibundle/asset_stamp'

module Jekyll::Minibundle
  class StampFile
    include AssetFileOperations
    include AssetFilePaths

    @@mtimes = {}

    attr_reader :asset_source_path, :asset_destination_dir

    def initialize(asset_source_path, asset_destination_path)
      @asset_source_path = asset_source_path
      @asset_destination_dir = File.dirname asset_destination_path
      @asset_destination_extension = File.extname asset_destination_path
      @asset_destination_base_prefix = File.basename(asset_destination_path)[0 .. -(@asset_destination_extension.size + 1)]
    end

    def last_mtime_of(path)
      @@mtimes[path]
    end

    def write(site_destination_dir)
      clear_asset_stamp if modified?

      if destination_is_up_to_date? site_destination_dir
        false
      else
        update_mtime
        write_destination site_destination_dir
        true
      end
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
