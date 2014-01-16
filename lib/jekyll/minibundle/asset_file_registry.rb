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

      def bundle_file(config)
        asset_destination_path = "#{config.fetch('destination_path')}.#{config.fetch('type')}"
        @_instances[asset_destination_path] ||= register_bundle_file(config)
      end

      def stamp_file(asset_source_path, asset_destination_path)
        @_instances[asset_destination_path] ||= register_stamp_file(asset_source_path, asset_destination_path)
      end

      private

      def register_bundle_file(config)
        if Environment.development?
          DevelopmentFileCollection.new(config)
        else
          BundleFile.new(config)
        end
      end

      def register_stamp_file(asset_source_path, asset_destination_path)
        StampFile.new(asset_source_path, asset_destination_path, &get_stamp_file_basenamer)
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
