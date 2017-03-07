require 'jekyll/minibundle/bundle_file'
require 'jekyll/minibundle/development_file'
require 'jekyll/minibundle/development_file_collection'
require 'jekyll/minibundle/environment'
require 'jekyll/minibundle/stamp_file'

module Jekyll::Minibundle
  module AssetFileRegistry
    class << self
      def clear_all
        @_files = {}
      end

      def clear_unused
        @_files
          .select { |_, cached| !cached.fetch(:is_used) }
          .each do |asset_destination_path, cached|
            cached.fetch(:file).cleanup
            @_files.delete(asset_destination_path)
          end

        @_files.each_value do |cached|
          cached[:is_used] = false
        end
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
          if cached.fetch(:type) != :bundle
            raise "minibundle block has the same destination path as a ministamp tag: #{asset_destination_path}"
          end

          cached_file = cached.fetch(:file)
          cached_config = cached.fetch(:config)
          cached_is_used = cached.fetch(:is_used)

          if bundle_config == cached_config
            unless cached_is_used
              cached[:is_used] = true
              add_as_static_files_to_site(site, get_files.call(cached_file))
            end

            return cached_file
          end

          if cached_is_used
            raise <<-END
Two or more minibundle blocks with the same destination path #{asset_destination_path.inspect}, but having different asset configuration: #{bundle_config.inspect} vs. #{cached_config.inspect}
            END
          end

          cached_file.cleanup
        end

        new_file = file_class.new(site, bundle_config)
        @_files[asset_destination_path] = {
          type:    :bundle,
          file:    new_file,
          config:  bundle_config,
          is_used: true
        }
        add_as_static_files_to_site(site, get_files.call(new_file))
        new_file
      end

      def register_file_for_stamp_tag(file_class, site, asset_source_path, asset_destination_path)
        cached = @_files[asset_destination_path]

        if cached
          if cached.fetch(:type) != :stamp
            raise "ministamp tag has the same destination path as a minibundle block: #{asset_destination_path}"
          end

          cached_file = cached.fetch(:file)
          cached_config = cached.fetch(:config)
          cached_is_used = cached.fetch(:is_used)

          if asset_source_path == cached_config
            unless cached_is_used
              cached[:is_used] = true
              add_as_static_files_to_site(site, [cached_file])
            end

            return cached_file
          end

          if cached_is_used
            raise <<-END
Two or more ministamp tags with the same destination path #{asset_destination_path.inspect}, but different asset source paths: #{asset_source_path.inspect} vs. #{cached_config.inspect}
            END
          end

          cached_file.cleanup
        end

        new_file = file_class.new(site, asset_source_path, asset_destination_path)
        @_files[asset_destination_path] = {
          type:    :stamp,
          file:    new_file,
          config:  asset_source_path,
          is_used: true
        }
        add_as_static_files_to_site(site, [new_file])
        new_file
      end

      def add_as_static_files_to_site(site, files)
        files.each { |file| site.static_files << file }
      end
    end

    clear_all
  end
end

::Jekyll::Hooks.register(:site, :post_write) do
  ::Jekyll::Minibundle::AssetFileRegistry.clear_unused
end
