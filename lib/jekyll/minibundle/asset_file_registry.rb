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

      def bundle_file(site, bundle_config)
        asset_destination_path = "#{bundle_config.fetch('destination_path')}.#{bundle_config.fetch('type')}"
        @_instances[asset_destination_path] ||= register_bundle_file(site, bundle_config)
      end

      def stamp_file(site, asset_source_path, asset_destination_path)
        @_instances[asset_destination_path] ||= register_stamp_file(site, asset_source_path, asset_destination_path)
      end

      private

      def register_bundle_file(site, bundle_config)
        if Environment.development?(site)
          DevelopmentFileCollection.new(site, bundle_config)
        else
          BundleFile.new(site, bundle_config)
        end
      end

      def register_stamp_file(site, asset_source_path, asset_destination_path)
        StampFile.new(site, asset_source_path, asset_destination_path, &get_stamp_file_basenamer(site))
      end

      def get_stamp_file_basenamer(site)
        if Environment.development?(site)
          ->(base, ext, _) { base + ext }
        else
          ->(base, ext, stamper) { "#{base}-#{stamper.call}#{ext}" }
        end
      end
    end

    clear
  end
end
