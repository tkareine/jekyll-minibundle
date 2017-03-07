require 'jekyll/minibundle/files'
require 'jekyll/minibundle/asset_file_properties'
require 'jekyll/minibundle/asset_stamp'

module Jekyll::Minibundle
  class StampFile
    include AssetFileProperties

    attr_reader :asset_source_path,
                :asset_destination_dir,
                :stamped_at

    def initialize(site, asset_source_path, asset_destination_path)
      @site = site
      @asset_source_path = File.join(@site.source, asset_source_path)
      raise ArgumentError, "Stamp source file does not exist: #{@asset_source_path}" unless File.file?(@asset_source_path)
      @asset_destination_dir = File.dirname(asset_destination_path)
      @asset_destination_extension = File.extname(asset_destination_path)
      @asset_destination_filename_prefix = File.basename(asset_destination_path)[0..-(@asset_destination_extension.size + 1)]
      @stamped_at = nil
      @is_modified = false
    end

    def cleanup
      # no-op
    end

    def destination_path_for_markup
      # we must rebundle here, if at all, in order to make sure the
      # destination path in the markup and the generated file path have
      # the same fingerprint

      source_mtime = mtime

      if @stamped_at != source_mtime
        @stamped_at = source_mtime
        @is_modified = true
        @_asset_stamp = nil
      end

      asset_destination_path
    end

    def asset_destination_filename
      "#{@asset_destination_filename_prefix}-#{asset_stamp}#{extname}"
    end

    def extname
      @asset_destination_extension
    end

    def modified?
      @is_modified
    end

    # allows writing destination only after
    # `destination_path_for_markup` has been called
    def write(site_destination_dir)
      if modified?
        Files.copy_p(path, destination(site_destination_dir))
        @is_modified = false
        true
      else
        false
      end
    end

    private

    def asset_stamp
      @_asset_stamp ||= AssetStamp.from_file(asset_source_path)
    end
  end
end
