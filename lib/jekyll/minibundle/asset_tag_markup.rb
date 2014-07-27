require 'cgi'

module Jekyll::Minibundle
  module AssetTagMarkup
    class << self
      def make_markup(type, path, attributes)
        case type
        when :js
          %{<script type="text/javascript" src="#{path}"#{make_attributes(attributes)}></script>}
        when :css
          %{<link rel="stylesheet" href="#{path}"#{make_attributes(attributes)}>}
        else
          fail ArgumentError, "Unknown type for generating bundle markup: #{type}, #{path}"
        end
      end

      def make_attributes(attributes)
        attributes.map { |name, value| make_attribute(name, value) }.join('')
      end

      def make_attribute(name, value)
        %{ #{name}="#{CGI.escape_html(value)}"}
      end
    end
  end
end
