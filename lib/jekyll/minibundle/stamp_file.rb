require 'jekyll/minibundle/asset_file_operations'
require 'jekyll/minibundle/asset_file_properties'
require 'jekyll/minibundle/asset_stamp'

module Jekyll::Minibundle
  class StampFile
    include AssetFileOperations
    include AssetFileProperties

    attr_reader :asset_source_path, :asset_destination_dir, :stamped_at

    def initialize(site, asset_source_path, asset_destination_path)
      @site = site
      @asset_source_path = File.join(@site.source, asset_source_path)
      @asset_destination_dir = File.dirname(asset_destination_path)
      @asset_destination_extension = File.extname(asset_destination_path)
      @asset_destination_base_prefix = File.basename(asset_destination_path)[0..-(@asset_destination_extension.size + 1)]
      @stamped_at = nil
      @is_modified = false
    end

    def destination_path_for_markup
      # we must regenerate the fingerprint here, if at all, in order
      # to make sure markup destination and generated file paths have
      # the same fingerprint
      if modified?
        @stamped_at = mtime
        @is_modified = true
        @_asset_stamp = nil
      end

      asset_destination_path
    end

    def extname
      @asset_destination_extension
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

    def asset_destination_basename
      "#{@asset_destination_base_prefix}-#{asset_stamp}#{extname}"
    end

    def asset_stamp
      @_asset_stamp ||= AssetStamp.from_file(path)
    end
  end
end
