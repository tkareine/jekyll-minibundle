require 'jekyll/minibundle/variable_template'

module Jekyll::Minibundle
  module VariableTemplateRegistry
    def self.clear
      @_templates = {}
    end

    def self.register_template(template)
      @_templates[template] ||= VariableTemplate.compile(template)
    end

    clear
  end
end

::Jekyll::Hooks.register(:site, :post_write) do
  ::Jekyll::Minibundle::VariableTemplateRegistry.clear
end
