require 'jekyll/minibundle/variable_template'

module Jekyll::Minibundle
  module VariableTemplateRegistry
    class << self
      def clear
        @_templates = {}
      end

      def register_template(template)
        @_templates[template] ||= VariableTemplate.compile(template)
      end
    end

    clear
  end
end

::Jekyll::Hooks.register(:site, :post_write) do
  ::Jekyll::Minibundle::VariableTemplateRegistry.clear
end
