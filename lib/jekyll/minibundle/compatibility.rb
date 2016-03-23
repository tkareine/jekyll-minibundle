module Jekyll::Minibundle
  module Compatibility
    LOG_TOPIC = 'Minibundle:'.freeze

    class << self
      # SafeYAML.load is introduced in Jekyll 2.0.0
      if defined?(::SafeYAML) && ::SafeYAML.respond_to?(:load)
        def load_yaml(*args)
          ::SafeYAML.load(*args)
        end
      else
        def load_yaml(*args)
          ::YAML.load(*args)
        end
      end

      # Jekyll.logger is introduced in Jekyll 1.0.3
      if ::Jekyll.respond_to?(:logger)
        def log_error(msg)
          ::Jekyll.logger.error(LOG_TOPIC, msg)
        end

        def log_info(msg)
          ::Jekyll.logger.info(LOG_TOPIC, msg)
        end
      else
        def log_error(msg)
          $stderr.puts(msg)
        end

        def log_info(msg)
          $stdout.puts(msg)
        end
      end
    end
  end
end
