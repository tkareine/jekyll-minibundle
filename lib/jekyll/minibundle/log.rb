# frozen_string_literal: true

module Jekyll::Minibundle
  module Log
    TOPIC = 'Minibundle:'

    def self.error(msg)
      ::Jekyll.logger.error(TOPIC, msg)
    end

    def self.info(msg)
      ::Jekyll.logger.info(TOPIC, msg)
    end
  end
end
