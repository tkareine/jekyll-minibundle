require 'jekyll/minibundle/environment'
require 'jekyll/minibundle/development_file_collection'
require 'jekyll/minibundle/bundle_file'
require 'jekyll/minibundle/stamp_file'

module Jekyll::Minibundle
  module AssetFileRegistry
    def self.clear
      @@_instances = {}
    end

    clear

    def self.bundle_file(config)
      asset_destination_path = "#{config['destination_path']}.#{config['type']}"
      @@_instances[asset_destination_path] ||= register_bundle_file config
    end

    def self.stamp_file(asset_source_path, asset_destination_path)
      @@_instances[asset_destination_path] ||= register_stamp_file asset_source_path, asset_destination_path
    end

    def self.register_bundle_file(config)
      if Environment.development?
        DevelopmentFileCollection.new config
      else
        BundleFile.new config
      end
    end

    private_class_method :register_bundle_file

    def self.register_stamp_file(asset_source_path, asset_destination_path)
      StampFile.new(asset_source_path, asset_destination_path, &get_stamp_file_basenamer)
    end

    private_class_method :register_stamp_file

    def self.get_stamp_file_basenamer
      if Environment.development?
        ->(base, ext, _) { base + ext }
      else
        ->(base, ext, stamper) { "#{base}-#{stamper.call}#{ext}" }
      end
    end

    private_class_method :get_stamp_file_basenamer
  end
end
