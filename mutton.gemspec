$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'mutton/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'mutton'
  s.version     = Mutton::VERSION
  s.authors     = ['SbbSoftware', 'Sean Chatterton']
  s.email       = ['sean.chatterton@sbbsoftware.com']
  s.homepage    = 'https://github.com/SBBSoftware/mutton'
  s.summary     = 'Handlebars on Rails'
  s.description = 'Handlebar templates on the server and the client'
  s.license     = 'MIT'

  s.files = Dir['{lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.rdoc']
  s.test_files = Dir['test/**/*']

  # TODO: change dependencies to a reasonable version
  s.add_dependency 'rails', '~> 4.2'
  s.add_dependency 'execjs'
  s.add_dependency 'tilt'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'poltergeist'
  s.add_development_dependency 'jquery-rails'
end
