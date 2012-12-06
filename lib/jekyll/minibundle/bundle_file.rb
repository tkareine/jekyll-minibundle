require 'fileutils'
require 'jekyll/minibundle/asset_bundle'

module Jekyll::Minibundle
  class BundleFile
    @@mtimes = Hash.new

    def initialize(config)
      @type = config['type']
      source_dir = File.join config['site_source'], config['source_dir']
      @destination_path = config['destination_path']
      @assets = config['assets'].map { |asset_path| File.join source_dir, "#{asset_path}.#{@type}" }
      update_mtime
    end

    def path
      asset_bundle.path
    end

    def asset_path
      "#{@destination_path}-#{asset_stamp}.#{@type}"
    end

    def destination(destination_base_dir)
      File.join destination_base_dir, asset_path
    end

    def mtime
      @assets.max { |f| File.stat(f).mtime.to_i }
    end

    def modified?
      @@mtimes[path] != mtime
    end

    def write(gensite_dir)
      rebundle_assets if modified?
      destination_path = destination gensite_dir

      return false if File.exist?(destination_path) and !modified?

      update_mtime
      write_destination gensite_dir

      true
    end

    def static_file!(site)
      site.static_files << self unless site.static_files.include? self
    end

    def markup
      %{<script type="text/javascript" src="#{asset_path}"></script>}
    end

    private

    def asset_stamp
      @asset_stamp ||= AssetStamp.from_file(path)
    end

    def asset_bundle
      @asset_bundle ||= AssetBundle.new(@type, @assets).make_bundle
    end

    def rebundle_assets
      @asset_stamp = nil
      asset_bundle.make_bundle
    end

    def update_mtime
      @@mtimes[path] = mtime
    end

    def write_destination(gensite_dir)
      destination_path = destination gensite_dir
      FileUtils.mkdir_p File.dirname(destination_path)
      FileUtils.cp path, destination_path
    end
  end
end
