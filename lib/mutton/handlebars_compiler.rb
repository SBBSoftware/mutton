module Mutton
  module HandlebarsCompiler
    module_function

    def pre_compile(source)
      source = source.read if source.respond_to?(:read)
      handlebar_context = ExecJS.compile(handlebars_source)
      handlebar_context.call('Handlebars.precompile', source)
    end

    def compile_handlebars(template_content, template_namespace, mutton_namespace, javascript_helpers = nil)
      ExecJS.compile("#{handlebars_source}; #{javascript_helpers}; #{template_content}; var template =  this.#{mutton_namespace}['#{template_namespace}'];")
    end

    def process_handlebars(template_content, template_namespace, mutton_namespace, assigns, javascript_helpers = nil)
      compiled = compile_handlebars(template_content, template_namespace, mutton_namespace, javascript_helpers)
      compiled.call('template', assigns.as_json)
    end

    # TODO: get from asset pipeline
    def handlebars_source
      Pathname(Mutton.handlebars_file).read
    end
  end
end
