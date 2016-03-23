require 'jekyll/minibundle/bundle_file'
require 'jekyll/minibundle/development_file'
require 'jekyll/minibundle/development_file_collection'
require 'jekyll/minibundle/environment'
require 'jekyll/minibundle/stamp_file'

module Jekyll::Minibundle
  module AssetFileRegistry
    class << self
      def clear
        @_files = {}
      end

      def register_bundle_file(site, bundle_config)
        register_file_for_bundle_block(BundleFile, site, bundle_config) { |file| [file] }
      end

      def register_development_file_collection(site, bundle_config)
        register_file_for_bundle_block(DevelopmentFileCollection, site, bundle_config, &:files)
      end

      def register_stamp_file(site, asset_source_path, asset_destination_path)
        register_file_for_stamp_tag(StampFile, site, asset_source_path, asset_destination_path)
      end

      def register_development_file(site, asset_source_path, asset_destination_path)
        register_file_for_stamp_tag(DevelopmentFile, site, asset_source_path, asset_destination_path)
      end

      private

      def register_file_for_bundle_block(file_class, site, bundle_config, &get_files)
        asset_destination_path = "#{bundle_config.fetch('destination_path')}.#{bundle_config.fetch('type')}"

        cached = @_files[asset_destination_path]

        if cached
          raise "minibundle block has same destination path as a ministamp tag: #{asset_destination_path}" if cached.fetch(:type) != :bundle

          cached_file = cached.fetch(:file)

          if bundle_config == cached.fetch(:config)
            get_files.call(cached_file).each do |file|
              site.static_files << file unless site.static_files.include?(file)
            end
            return cached_file
          else
            get_files.call(cached_file).each { |file| site.static_files.delete(file) }
          end
        end

        new_file = file_class.new(site, bundle_config)
        @_files[asset_destination_path] = {type: :bundle, file: new_file, config: bundle_config}
        get_files.call(new_file).each { |file| site.static_files << file }
        new_file
      end

      def register_file_for_stamp_tag(file_class, site, asset_source_path, asset_destination_path)
        cached = @_files[asset_destination_path]

        if cached
          raise "ministamp tag has same destination path as a minibundle block: #{asset_destination_path}" if cached.fetch(:type) != :stamp

          cached_file = cached.fetch(:file)

          if asset_source_path == cached.fetch(:config)
            site.static_files << cached_file unless site.static_files.include?(cached_file)
            return cached_file
          else
            site.static_files.delete(cached_file)
          end
        end

        new_file = file_class.new(site, asset_source_path, asset_destination_path)
        @_files[asset_destination_path] = {type: :stamp, file: new_file, config: asset_source_path}
        site.static_files << new_file
        new_file
      end
    end

    clear
  end
end
