require 'jekyll/minibundle/asset_file_operations'
require 'jekyll/minibundle/asset_file_paths'

module Jekyll::Minibundle
  class DevelopmentFile
    include AssetFileOperations
    include AssetFilePaths

    attr_reader :asset_source_path, :asset_destination_dir, :asset_destination_basename, :stamped_at

    def initialize(asset_source_path, asset_destination_path)
      @asset_source_path = asset_source_path
      @asset_destination_dir = File.dirname(asset_destination_path)
      @asset_destination_basename = File.basename(asset_destination_path)
      @stamped_at = nil
    end

    def write(site_destination_dir)
      if modified?
        @stamped_at = mtime
        write_destination(site_destination_dir)
        true
      else
        false
      end
    end
  end
end
