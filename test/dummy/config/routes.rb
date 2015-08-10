Rails.application.routes.draw do
  get '/codeless/:action', controller: 'codeless'
  get '/samples/:action', controller: 'samples'
  get '/libraries/:action', controller: 'libraries'
  get '/examples/:action', controller: 'examples'
end
