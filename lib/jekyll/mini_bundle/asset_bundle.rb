# encoding: utf-8

module Jekyll::MiniBundle
  module AssetBundle
    def self.for(type, *args)
      case type
      when :css
        require 'jekyll/mini_bundle/asset_bundler/yui_compressor'
        AssetBundler::YUICompressor
      else
        raise ArgumentError, "Unknown asset bundle type: #{type}"
      end.new(type, *args)
    end
  end
end
