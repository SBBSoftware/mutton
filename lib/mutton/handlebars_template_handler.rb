require_relative 'handlebars_compiler'
module Mutton
  class HandlebarsTemplateHandler

    # template handler contract this is called from rendering stack
    def self.call(template)
      "Mutton::HandlebarsTemplateHandler.new(self).render_handlebars(#{template.virtual_path.inspect}, Rails.application.assets, assigns)"
    end

    def initialize(view)
      # not used in this version
      @view = view
    end

    def render_handlebars(virtual_path, asset_environment, assigns = {})
      timing = {}
      ActiveSupport::Notifications.instrument 'render_template.Mutton', timing do
        start_time = Time.zone.now
        # get every hbs file name and pull from sprockets
        handlebar_content = template_content(asset_environment)
        end_content_time= Time.zone.now
        # get custom javascript from the helper directory
        javascript_helpers = custom_javascript(Rails.application.assets, Mutton.helper_path)
        start_compile_time = Time.zone.now
        # compile it
        result = HandlebarsCompiler.process_handlebars(handlebar_content, virtual_path, Mutton.template_namespace, assigns.as_json, javascript_helpers)
        end_compile_time = Time.zone.now
        content_retrieval_time = ((end_content_time - start_time) * 1000).round(0)
        compile_time = ((end_compile_time - start_compile_time) * 1000).round(0)
        timing[:compile_time] = compile_time
        timing[:content_retrieval_time] = content_retrieval_time
        result.html_safe
      end
    end

    def template_content(asset_environment)
      handlebar_content = ''
      asset_environment.each_file.select { |x| x.ends_with?('.hbs') || x.ends_with?('.handlebars') }.each do |asset|
        content = Rails.application.assets[asset]
        handlebar_content << content.source
      end
      handlebar_content
    end

    def custom_javascript(asset_environment, helper_path, _options = {})
      # get everything from the helper directory
      javascript_content = ''
      javascript_helpers = asset_environment.each_file.select { |x| x.starts_with?(helper_path) }
      javascript_helpers.each do |helper|
        javascript_content << File.new(helper, 'r').read
      end
      javascript_content
    end
  end
end
