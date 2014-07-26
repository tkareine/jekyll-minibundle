module Jekyll::Minibundle
  module Environment
    class << self
      def minifier_command_for(type)
        ENV["JEKYLL_MINIBUNDLE_CMD_#{type.upcase}"]
      end

      def development?
        ENV['JEKYLL_MINIBUNDLE_MODE'] == 'development'
      end
    end
  end
end
