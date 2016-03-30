require 'jekyll/minibundle/development_file'

module Jekyll::Minibundle
  class DevelopmentFileCollection
    attr_reader :files

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

    def cleanup
      # no-op
    end
  end
end
