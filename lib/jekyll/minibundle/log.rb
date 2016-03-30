module Jekyll::Minibundle
  module Log
    TOPIC = 'Minibundle:'.freeze

    class << self
      def error(msg)
        ::Jekyll.logger.error(TOPIC, msg)
      end

      def info(msg)
        ::Jekyll.logger.info(TOPIC, msg)
      end
    end
  end
end
