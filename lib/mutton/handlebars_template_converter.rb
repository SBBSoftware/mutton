require_relative 'handlebars_compiler'

module Mutton
  # convert hbs files into javascript for the asset pipeline
  class HandlebarsTemplateConverter < Tilt::Template

    def self.default_mime_type
      'application/javascript'
    end

    # no changes implemented
    def initialize_engine
    end

    # no changes implemented
    def prepare
    end

    # called by sprockets when compiling
    def evaluate(scope, _locals, &_block)
      timing = {}
      ActiveSupport::Notifications.instrument 'evaluate_asset.Mutton', timing do
        start_time = Time.zone.now
        # clients require precompiled templates for optimization
        precompiled_template = HandlebarsCompiler.pre_compile(data)
        end_precompile_time = Time.zone.now
        start_write_source = Time.zone.now
        source = write_source(precompiled_template, scope.logical_path, Mutton.template_namespace)
        end_time = Time.zone.now
        precompile_time = ((end_precompile_time - start_time) * 1000).round(0)
        source_time = ((end_time - start_write_source) * 1000).round(0)
        timing[:precompile_time] = precompile_time
        timing[:source_time] = source_time
        source
      end
    end

    def write_source(code, path, namespace)
      # drop the first bit of path to get rid of root directory
      paths = path.split('/')
      paths.delete_at(0)
      virtual_path = paths.join('/')
      write_template(namespace, virtual_path, code)
    end

    def write_template(namespace, virtual_path, source)
      javascript_code = <<CODE
(function() {
    var template = Handlebars.template,
        templates = this.#{namespace} = this.#{namespace} || {};
    templates['#{virtual_path}'] = template(
    #{source}
    );
    Handlebars.partials = this.#{namespace};
})(this);
//best with a large serving of mutton
CODE
      javascript_code
    end
  end
end
