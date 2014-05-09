require 'fileutils'

module Jekyll::Minibundle
  module AssetFileOperations
    def add_as_static_file_to(site)
      # NOTE: Rely on explicit site parameter (not on self's @site) so
      # that we can utilize asset registry clearing for tests.
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
