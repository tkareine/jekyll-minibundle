require 'fileutils'

module Jekyll::Minibundle
  module AssetFileOperations
    def cleanup
      # defaults to no-op
    end

    def write_destination(site_destination_dir)
      destination_path = destination(site_destination_dir)
      FileUtils.mkdir_p(File.dirname(destination_path))
      FileUtils.cp(path, destination_path)
    end
  end
end
