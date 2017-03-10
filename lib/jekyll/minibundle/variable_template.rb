require 'strscan'

module Jekyll::Minibundle
  class VariableTemplate
    OPEN_TAG = '{{'.freeze
    CLOSE_TAG = '}}'.freeze
    ESCAPE_CHAR = '\\'.freeze

    def initialize(interpolation)
      instance_eval("def render(variables) #{interpolation} end", __FILE__, __LINE__)
    end

    def self.compile(template)
      new(Generator.compile(Parser.parse(template)))
    end

    class SyntaxError < ArgumentError
      CURSOR = '@'.freeze

      def initialize(message, template, position)
        @message = message
        @template = template
        @position = position
      end

      def to_s
        template_before_pos = @template[0, @position]
        template_after_pos = @template[@position..-1]

        <<-END
#{@message} at position #{@position} in template (position highlighted with "#{CURSOR}"):
#{template_before_pos}#{CURSOR}#{template_after_pos}
        END
      end
    end

    module Parser
      # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def self.parse(template)
        raise ArgumentError, 'Nil template' if template.nil?

        escape_or_open_regex = Parser.make_escape_sequence_or_open_tag_regexp
        close_regex = Parser.make_close_tag_regexp

        scanner = StringScanner.new(template)

        tokens = []
        text_buffer = ''
        escape_or_open_match = scanner.scan_until(escape_or_open_regex)

        while escape_or_open_match
          escape_match = scanner[1]

          # escape sequence
          if escape_match
            text_buffer += escape_or_open_match[0..-3]
            text_buffer += escape_match[1, 1]
          # open tag
          else
            text_buffer += escape_or_open_match[0..-(OPEN_TAG.size + 1)]
            tokens << Token.text(text_buffer)
            text_buffer = ''
            close_match = scanner.scan_until(close_regex)
            raise SyntaxError.new(%{Missing closing tag ("#{CLOSE_TAG}") for variable opening tag ("#{OPEN_TAG}")}, template, scanner.charpos) unless close_match
            tokens << Token.variable(close_match[0..-(CLOSE_TAG.size + 1)].strip)
          end

          escape_or_open_match = scanner.scan_until(escape_or_open_regex)
        end

        text_buffer += scanner.rest unless scanner.eos?
        tokens << Token.text(text_buffer) unless text_buffer.empty?

        tokens
      end
      # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      def self.make_escape_sequence_regexp
        escape_chars = (OPEN_TAG + CLOSE_TAG).chars.uniq
        escape_chars << ESCAPE_CHAR
        escape_chars.map { |c| Regexp.escape(ESCAPE_CHAR + c) }
      end

      def self.make_escape_sequence_or_open_tag_regexp
        @_escape_sequence_or_open_tag_regexp ||=
          begin
            regexp = [make_escape_sequence_regexp.join('|'), Regexp.escape(OPEN_TAG)].map { |p| "(#{p})" }.join('|')
            Regexp.compile(regexp)
          end
      end

      def self.make_close_tag_regexp
        @_close_tag_regexp ||= Regexp.compile(Regexp.escape(CLOSE_TAG))
      end
    end

    class Token
      attr_reader :value

      def initialize(value, is_variable)
        @value = value
        @is_variable = is_variable
      end

      def variable?
        @is_variable
      end

      def self.text(value)
        new(value, false)
      end

      def self.variable(value)
        new(value, true)
      end
    end

    # Transforms array of tokens to Ruby interpolation string.
    #
    # Idea adapted from Mustache's
    # [Generator](https://github.com/mustache/mustache/blob/master/lib/mustache/generator.rb).
    module Generator
      def self.compile(tokens)
        result = '"'

        tokens.each do |token|
          result +=
            if token.variable?
              %(#\{variables["#{escape_token(token.value)}"].to_s})
            else
              escape_token(token.value)
            end
        end

        result += '"'

        result
      end

      def self.escape_token(token)
        token.inspect[1..-2]
      end
    end
  end
end
