module Jekyll::Minibundle
  module BundleMarkup
    def self.make_markup(type, path, attributes)
      case type
      when :js
        %{<script type="text/javascript" src="#{path}"#{make_attributes(attributes)}></script>}
      when :css
        %{<link rel="stylesheet" href="#{path}"#{make_attributes(attributes)}>}
      else
        raise "Unknown type for generating bundle markup: #{type}, #{path}"
      end
    end

    def self.make_attributes(attributes)
      attributes.map { |name, value| %{ #{name}="#{value}"} }.join('')
    end
  end
end
