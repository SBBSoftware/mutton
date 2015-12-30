module Mutton
  # TODO: are we really using an engine?
  # class Engine < ::Rails::Railtie
  class Engine < ::Rails::Engine

    isolate_namespace Mutton

    config.before_configuration do |app|
      # add the default template to rails view paths
      # rails ignores any changes after this event, bastard.
      app.paths['app/views'] << Mutton.default_template_path.to_s
    end

    config.after_initialize do
      # FIXME: maximum suckage
      # rails will ignore paths set during this event so we need to
      # carry out this workaround
      # if a controller is reloaded dynamically, it will lose this setting and really suck
      ApplicationController.send(:append_view_path, Mutton.template_path.to_s) unless Mutton.template_path == Mutton.default_template_path
    end

    initializer 'mutton.initialize', group: :all do |app|
      # must have sprockets or you're in trouble
      # TODO: no longer works with Rails 4.25, changing to test Sprockets module is loaded
      # fail('Sprockets Not Found. This version does not work without sprockets') unless app.assets
      fail('Sprockets Not Found. This version does not work without sprockets') unless Module.const_defined?('Sprockets')

      # set logger to rails logger
      Mutton.logger = Rails.logger
      # register with sprockets for hbs and handlebar files
      # Quick fix for Rails 4.25
      Sprockets.register_engine('.hbs', HandlebarsTemplateConverter, mime_type: 'application/javascript')
      Sprockets.register_engine('.handlebars', HandlebarsTemplateConverter, mime_type: 'application/javascript')
      # TODO: below broken in Rails 4.25, changed to register through Sprockets
      # app.assets.register_engine('.hbs', HandlebarsTemplateConverter, mime_type: 'application/javascript')
      # app.assets.register_engine('.handlebars', HandlebarsTemplateConverter, mime_type: 'application/javascript')
      # register template handler with Rails
      ActionView::Template.register_template_handler(:hbs, :handlebars, Mutton::HandlebarsTemplateHandler)
      # TODO: dont register a diretory if it is already part of the sprockets path?
      # add assets to sprockets path
      app.config.assets.paths << Mutton.sprockets_path
    end
  end
end
