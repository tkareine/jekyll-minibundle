require 'fileutils'

module Jekyll::Minibundle
  module AssetFileOperations
    def static_file!(site)
      unless site.static_files.include? self
        site.static_files << self
      end
    end

    def write_destination(site_destination_dir)
      destination_path = destination(site_destination_dir)
      FileUtils.mkdir_p(File.dirname(destination_path))
      FileUtils.cp(path, destination_path)
    end
  end
end
