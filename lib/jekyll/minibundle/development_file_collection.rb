require 'jekyll/minibundle/development_file'

module Jekyll::Minibundle
  class DevelopmentFileCollection
    def initialize(site, config)
      @type = config.fetch('type')
      asset_source_dir = File.join(site.source, config.fetch('source_dir'))
      destination_path = config.fetch('destination_path')

      @files = config.fetch('assets').map do |asset_path|
        asset_basename = "#{asset_path}.#{@type}"
        asset_source = File.join(asset_source_dir, asset_basename)
        asset_destination = File.join(destination_path, asset_basename)
        DevelopmentFile.new(site, asset_source, asset_destination)
      end
    end

    def add_as_static_file_to(site)
      # NOTE: We could optimize here by iterating over site's static
      # files only once instead of per each of our file. Seems like a
      # premature optimization for now, however.
      @files.each { |f| f.add_as_static_file_to(site) }
    end

    def destination_paths_for_markup
      @files.map(&:asset_destination_path)
    end
  end
end
