require 'jekyll/minibundle/environment'
require 'jekyll/minibundle/development_file_collection'
require 'jekyll/minibundle/bundle_file'
require 'jekyll/minibundle/stamp_file'

module Jekyll::Minibundle
  module AssetFileRegistry
    class << self
      def clear
        @_instances = {}
      end

      def bundle_file(site, config)
        asset_destination_path = "#{config.fetch('destination_path')}.#{config.fetch('type')}"
        @_instances[asset_destination_path] ||= register_bundle_file(site, config)
      end

      def stamp_file(site, asset_source_path, asset_destination_path)
        @_instances[asset_destination_path] ||= register_stamp_file(site, asset_source_path, asset_destination_path)
      end

      private

      def register_bundle_file(site, config)
        if Environment.development?
          DevelopmentFileCollection.new(site, config)
        else
          BundleFile.new(site, config)
        end
      end

      def register_stamp_file(site, asset_source_path, asset_destination_path)
        StampFile.new(site, asset_source_path, asset_destination_path, &get_stamp_file_basenamer)
      end

      def get_stamp_file_basenamer
        if Environment.development?
          ->(base, ext, _) { base + ext }
        else
          ->(base, ext, stamper) { "#{base}-#{stamper.call}#{ext}" }
        end
      end
    end

    clear
  end
end
