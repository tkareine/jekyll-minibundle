module Jekyll::Minibundle
  module Environment
    def self.command_for(type)
      key = "JEKYLL_MINIBUNDLE_CMD_#{type.upcase}"
      cmd = ENV[key]
      raise "You need to set command for minification in $#{key}" if !cmd
      cmd
    end

    def self.development?
      ENV['JEKYLL_MINIBUNDLE_MODE'] == 'development'
    end
  end
end
