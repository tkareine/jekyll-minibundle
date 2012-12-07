require 'yaml'
require 'jekyll/minibundle/bundle_file'

module Jekyll::Minibundle
  class MiniBundleBlock < Liquid::Block
    def initialize(tag_name, type, _tokens)
      super
      @type = type.strip.to_sym
    end

    def render(context)
      current_config = YAML.load super
      site = context.registers[:site]
      config = default_config.
        merge(current_config).
        merge({ 'type' => @type, 'site_dir' => site.source})
      file = BundleFile.new config
      file.static_file! site
      file.markup
    end

    def default_config
      {
        'source_dir'        => '_assets',
        'destination_path'  => 'assets/site',
        'assets'            => [],
        'attributes'        => {}
      }
    end
  end
end

Liquid::Template.register_tag('minibundle', Jekyll::Minibundle::MiniBundleBlock)
