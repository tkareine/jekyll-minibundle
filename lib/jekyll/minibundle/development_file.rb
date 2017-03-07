require 'jekyll/minibundle/files'
require 'jekyll/minibundle/asset_file_properties'

module Jekyll::Minibundle
  class DevelopmentFile
    include AssetFileProperties

    attr_reader :asset_source_path,
                :asset_destination_dir,
                :asset_destination_filename,
                :stamped_at

    def initialize(site, asset_source_path, asset_destination_path)
      @site = site
      @asset_source_path = File.join(@site.source, asset_source_path)
      raise ArgumentError, "Development source file does not exist: #{@asset_source_path}" unless File.file?(@asset_source_path)
      @asset_destination_dir = File.dirname(asset_destination_path)
      @asset_destination_filename = File.basename(asset_destination_path)
      @stamped_at = nil
    end

    def cleanup
      # no-op
    end

    alias destination_path_for_markup asset_destination_path

    def extname
      File.extname(asset_destination_filename)
    end

    def modified?
      stamped_at != mtime
    end

    def write(site_destination_dir)
      if modified?
        @stamped_at = mtime
        Files.copy_p(path, destination(site_destination_dir))
        true
      else
        false
      end
    end
  end
end
