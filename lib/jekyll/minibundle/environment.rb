module Jekyll::Minibundle
  module Environment
    class << self
      def command_for(type)
        key = "JEKYLL_MINIBUNDLE_CMD_#{type.upcase}"
        ENV.fetch(key) { fail "You need to set command for minification in $#{key}" }
      end

      def development?
        ENV['JEKYLL_MINIBUNDLE_MODE'] == 'development'
      end
    end
  end
end
