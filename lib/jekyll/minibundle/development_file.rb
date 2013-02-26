require 'jekyll/minibundle/asset_file_operations'
require 'jekyll/minibundle/asset_file_paths'

module Jekyll::Minibundle
  class DevelopmentFile
    include AssetFileOperations
    include AssetFilePaths

    @@mtimes = {}

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
      if destination_exists?(site_destination_dir) && !modified?
        false
      else
        @@mtimes[path] = mtime
        write_destination site_destination_dir
        true
      end
    end
  end
end
