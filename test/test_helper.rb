# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

require File.expand_path('../../test/dummy/config/environment.rb',  __FILE__)
# ActiveRecord::Migrator.migrations_paths = [File.expand_path('../../test/dummy/db/migrate', __FILE__)]
require 'rails/test_help'
require 'capybara/rails'
# require 'capybara-webkit'
require 'capybara/poltergeist'
Capybara.default_driver = :rack_test
Capybara.javascript_driver = :poltergeist
Capybara.current_driver = Capybara.javascript_driver
# NOTES: to get jquery working need to require it in application.rb, add it to gemspec as a dependency

# Filter out Minitest backtrace while allowing backtrace from other libraries
# to be shown.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

class ActionDispatch::IntegrationTest
  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL
  include WaitForAjax

  def current_path
    URI.parse(current_url).request_uri
  end
end
