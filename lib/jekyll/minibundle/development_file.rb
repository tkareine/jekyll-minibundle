require 'jekyll/minibundle/asset_file_operations'
require 'jekyll/minibundle/asset_file_paths'

module Jekyll::Minibundle
  class DevelopmentFile
    include AssetFileOperations
    include AssetFilePaths

    @@mtimes = Hash.new

    attr_reader :asset_source_path, :asset_destination_dir, :asset_destination_basename

    def initialize(asset_source_path, asset_destination_path)
      @asset_source_path = asset_source_path
      @asset_destination_dir = File.dirname asset_destination_path
      @asset_destination_basename = File.basename asset_destination_path
    end

    def last_mtime_of(path)
      @@mtimes[path]
    end

    def write(site_destination_dir)
      if destination_is_up_to_date? site_destination_dir
        false
      else
        update_mtime
        write_destination site_destination_dir
        true
      end
    end

    private

    def update_mtime
      @@mtimes[path] = mtime
    end
  end
end
