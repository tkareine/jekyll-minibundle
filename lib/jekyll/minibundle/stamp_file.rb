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
      destination_path = destination gensite_dir

      return false if File.exist?(destination_path) and !modified?

      clear_stamp
      update_mtime
      write_destination gensite_dir

      true
    end

    def static_file!(site)
      site.static_files.reject! { |f| f.path == path }
      site.static_files << self
    end

    private

    def destination_basename
      "#{@destination_base_prefix}-#{stamp}#{@destination_extension}"
    end

    def stamp
      @stamp ||= AssetStamp.for(path)
    end

    def clear_stamp
      @stamp = nil
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
