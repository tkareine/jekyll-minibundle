require 'fileutils'

module Jekyll::Minibundle
  module AssetFileOperations
    def static_file!(site)
      check_no_existing_static_file site.static_files
      site.static_files << self
    end

    def check_no_existing_static_file(static_files)
      found = static_files.find { |f| f.path == path }
      raise "Minibundle cannot handle static file already handled by Jekyll: #{path}" if found
    end

    def write_destination(site_destination_dir)
      destination_path = destination site_destination_dir
      FileUtils.mkdir_p File.dirname(destination_path)
      FileUtils.cp path, destination_path
    end
  end
end
