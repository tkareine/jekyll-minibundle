require 'jekyll/minibundle/asset_file_operations'
require 'jekyll/minibundle/asset_file_properties'

module Jekyll::Minibundle
  class DevelopmentFile
    include AssetFileOperations
    include AssetFileProperties

    attr_reader :asset_source_path, :asset_destination_dir, :asset_destination_basename, :stamped_at

    def initialize(site, asset_source_path, asset_destination_path)
      @site = site
      @asset_source_path = asset_source_path
      @asset_destination_dir = File.dirname(asset_destination_path)
      @asset_destination_basename = File.basename(asset_destination_path)
      @stamped_at = nil
    end

    alias destination_path_for_markup asset_destination_path

    def extname
      File.extname(asset_destination_path)
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
