# encoding: utf-8

require 'jekyll/minibundle/asset_bundler/base_asset_bundler'

module Jekyll::Minibundle::AssetBundler
  class YUICompressor < BaseAssetBundler
    def markup
      Tempfile.open('jekyll-mini_bundle') do |tempfile|
        yui_compressor_jar = site_config['mini_bundle']['yui_compressor_jar']
        IO.popen("java -jar #{yui_compressor_jar} -v --charset=utf-8 --type=#{type} -o #{tempfile.path}", 'w') do |pipe|
          asset_paths.each do |asset|
            puts "  #{asset}"
            IO.foreach(asset) do |line|
              pipe << line
            end
          end
        end
        path_to_bundle = bundle_path tempfile
        FileUtils.mkdir_p path_to_bundle.dirname
        FileUtils.cp tempfile.path, path_to_bundle
        # TODO: Add to registry, then move to _site generator that produces BundleFiles
        css_markup_tag path_to_bundle
      end
    end
  end
end
