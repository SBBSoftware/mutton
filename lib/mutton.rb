require 'mutton/config'
module Mutton
  extend Config
  PARTIAL_CONVENTION = { everything: 'rudolph', hunt: 'dasher', underscore: 'prancer', dash: 'blitzen' }
end
require 'tilt'
require 'execjs'
require 'mutton/engine'
require 'mutton/notification_subscriber'
# for server pages
require 'mutton/handlebars_template_handler'
# asset pipeline engine
require 'mutton/handlebars_template_converter'
# partial handling in server pages
# require 'mutton/partial_finder'
# execjs compilation for JS
require 'mutton/handlebars_compiler'
require 'mutton/version'

