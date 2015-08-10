module Mutton
  module Config
    attr_writer :template_path, :template_namespace,
                :javascript_asset_path, :handlebars_file

    # provide a custom logger if you are magically using this from outside
    # rails. logger is set during engine configuration ti Rails.logger
    attr_accessor :logger

    def configure
      yield self
    end

    # path to templates directory
    def template_path
      @template_path ||= Rails.root.join('app', 'assets', 'javascripts', 'templates')
      # @template_path ||= Rails.root.join('app', 'handlebars', 'templates')
    end

    # path to javascript helpers
    # every javascript file in this directory will be concatenated with
    # handlebars during compilation
    def helper_path
      @helper_path ||= File.join(Mutton.template_path, 'helpers')
    end

    # javascript namespace for compiled templates
    # templates will be accessed by this value
    # JHT['directory/file_without_extension']
    def template_namespace
      @template_namespace ||= 'JHT'
    end

    # handlebars file for compilation
    # change this if you want to use a beta or other version
    # you dont need to wait for a gem update if handlebars
    # releases a new version
    def handlebars_file
      # don't want to force the user to serve my handlebars.js from sprockets so...
      @handlebars_file ||= File.expand_path('../../../vendor/assets/javascripts/mutton/handlebars.js', __FILE__)
    end

    # when true, instrumentation will be logged at debug level
    def subscribe_notifications
      @subscribe_notifications ||= true
    end

    alias_method :subscribe_notifications?, :subscribe_notifications

    # read only properties

    # sprockets needs to know where hbs files are stored
    # its 1 up from the template path in sprockets-speak
    def sprockets_path
      File.expand_path('../', Mutton.template_path)
    end

    # shipped default path
    def default_template_path
      # Rails.root.join('app', 'handlebars', 'templates')
      Rails.root.join('app', 'assets', 'javascripts', 'templates')
    end

    # shipped version of handlebars
    def vendor_version
      'v3.0.3'
    end
  end
end
