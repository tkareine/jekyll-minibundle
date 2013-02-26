require 'jekyll/minibundle/asset_file_operations'
require 'jekyll/minibundle/asset_file_paths'
require 'jekyll/minibundle/asset_stamp'

module Jekyll::Minibundle
  class StampFile
    include AssetFileOperations
    include AssetFilePaths

    @@mtimes = {}

    attr_reader :asset_source_path, :asset_destination_dir

    def initialize(asset_source_path, asset_destination_path, &basenamer)
      @basenamer = basenamer
      @asset_source_path = asset_source_path
      @asset_destination_dir = File.dirname asset_destination_path
      @asset_destination_extension = File.extname asset_destination_path
      @asset_destination_base_prefix = File.basename(asset_destination_path)[0 .. -(@asset_destination_extension.size + 1)]
      @was_modified = false
    end

    def markup
      # we must regenerate the fingerprint here, if at all, in order
      # to make sure the markup and generated file have the same
      # fingerprint
      if modified?
        @asset_stamp = nil
        @@mtimes[path] = mtime
        @was_modified = true
      else
        @was_modified = false
      end

      asset_destination_path
    end

    def last_mtime_of(path)
      @@mtimes[path]
    end

    def write(site_destination_dir)
      if destination_exists?(site_destination_dir) && !@was_modified
        false
      else
        write_destination site_destination_dir
        true
      end
    end

    private

    def asset_destination_basename
      @basenamer.call @asset_destination_base_prefix, @asset_destination_extension, -> { asset_stamp }
    end

    def asset_stamp
      @asset_stamp ||= AssetStamp.from_file(path)
    end
  end
end
