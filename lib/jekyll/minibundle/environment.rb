require 'jekyll/minibundle/hashes'

module Jekyll::Minibundle
  module Environment
    def self.minifier_command(site, type)
      type = type.to_s
      ENV["JEKYLL_MINIBUNDLE_CMD_#{type.upcase}"] || Environment.find_site_config(site, ['minibundle', 'minifier_commands', type], String)
    end

    def self.development?(site)
      mode = ENV['JEKYLL_MINIBUNDLE_MODE'] || Environment.find_site_config(site, %w{minibundle mode}, String)
      mode == 'development'
    end

    def self.find_site_config(site, keys, type)
      value = Hashes.dig(site.config, *keys)
      if value && !value.is_a?(type)
        raise "Invalid site configuration for key #{keys.join('.')}; expecting type #{type}"
      end
      value
    end
  end
end
