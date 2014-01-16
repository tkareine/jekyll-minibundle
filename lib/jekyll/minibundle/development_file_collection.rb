require 'jekyll/minibundle/asset_tag_markup'
require 'jekyll/minibundle/development_file'

module Jekyll::Minibundle
  class DevelopmentFileCollection
    def initialize(config)
      @type = config.fetch('type')
      asset_source_dir = File.join(config.fetch('site_dir'), config.fetch('source_dir'))
      destination_path = config.fetch('destination_path')

      @files = config.fetch('assets').map do |asset_path|
        asset_basename = "#{asset_path}.#{@type}"
        asset_source = File.join(asset_source_dir, asset_basename)
        asset_destination = File.join(destination_path, asset_basename)
        DevelopmentFile.new(asset_source, asset_destination)
      end

      @attributes = config.fetch('attributes')
    end

    def static_file!(site)
      # NOTE: We could optimize here by iterating over site's static
      # files only once instead of per each of our file. Seems like a
      # premature optimization for now, however.
      @files.each { |f| f.static_file!(site) }
    end

    def markup
      @files.
        map { |f| AssetTagMarkup.make_markup(@type, f.asset_destination_path, @attributes) }.
        join("\n")
    end
  end
end
