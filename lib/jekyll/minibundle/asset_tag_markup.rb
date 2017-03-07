require 'cgi'

module Jekyll::Minibundle
  module AssetTagMarkup
    def self.make_markup(type, path, attributes)
      case type
      when :js
        %{<script type="text/javascript" src="#{path}"#{make_attributes(attributes)}></script>}
      when :css
        %{<link rel="stylesheet" href="#{path}"#{make_attributes(attributes)}>}
      else
        raise ArgumentError, "Unknown type for generating bundle markup: #{type}, #{path}"
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
