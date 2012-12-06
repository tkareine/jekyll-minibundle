require 'fileutils'
require 'jekyll/minibundle/asset_stamp'

module Jekyll::Minibundle
  class StampFile
    @@mtimes = Hash.new

    def initialize(source_path, destination_path)
      @source_path = source_path
      @destination_dir = File.dirname destination_path
      @destination_extension = File.extname destination_path
      base = File.basename destination_path
      @destination_base_prefix = base[0, @destination_extension.size]
      update_mtime
    end

    def path
      @source_path
    end

    def asset_path
      File.join @destination_dir, destination_basename
    end

    def destination(gensite_dir)
      File.join gensite_dir, @destination_dir, destination_basename
    end

    def mtime
      File.stat(path).mtime.to_i
    end

    def modified?
      @@mtimes[path] != mtime
    end

    def write(gensite_dir)
      clear_asset_stamp if modified?
      destination_path = destination gensite_dir

      return false if File.exist?(destination_path) and !modified?

      update_mtime
      write_destination gensite_dir

      true
    end

    def static_file!(site)
      site.static_files << self unless site.static_files.include? self
    end

    private

    def destination_basename
      "#{@destination_base_prefix}-#{asset_stamp}#{@destination_extension}"
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

    def write_destination(gensite_dir)
      destination_path = destination gensite_dir
      FileUtils.mkdir_p File.dirname(destination_path)
      FileUtils.cp path, destination_path
    end
  end
end
