require 'cgi'

module Jekyll::Minibundle
  module AssetTagMarkup
    class << self
      def make_markup(type, baseurl, path, attributes)
        url = make_url(baseurl, path)
        case type
        when :js
          %{<script type="text/javascript" src="#{url}"#{make_attributes(attributes)}></script>}
        when :css
          %{<link rel="stylesheet" href="#{url}"#{make_attributes(attributes)}>}
        else
          raise ArgumentError, "Unknown type for generating bundle markup: #{type}, #{path}"
        end
      end

      def make_attributes(attributes)
        attributes.map { |name, value| make_attribute(name, value) }.join('')
      end

      def make_attribute(name, value)
        if value.nil?
          %{ #{name}}
        else
          %{ #{name}="#{CGI.escape_html(value.to_s)}"}
        end
      end

      def make_url(baseurl, path)
        if baseurl.empty?
          path
        else
          File.join(baseurl, path)
        end
      end
    end
  end
end
