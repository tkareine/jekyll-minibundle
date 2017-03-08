require 'cgi/util'

module Jekyll::Minibundle
  module AssetTagMarkup
    def self.make_markup(type, url, attributes)
      url_str = CGI.escape_html(url)
      attributes_str = make_attributes(attributes)

      case type
      when :js
        %{<script type="text/javascript" src="#{url_str}"#{attributes_str}></script>}
      when :css
        %{<link rel="stylesheet" href="#{url_str}"#{attributes_str}>}
      else
        raise ArgumentError, "Unknown type for generating bundle markup: #{type}, #{url}"
      end
    end

    def self.make_attributes(attributes)
      attributes.map { |name, value| make_attribute(name, value) }.join('')
    end

    def self.make_attribute(name, value)
      if value.nil?
        %{ #{name}}
      else
        %{ #{name}="#{CGI.escape_html(value.to_s)}"}
      end
    end
  end
end
