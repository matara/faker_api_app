# Rack::Test
ENV['RACK_ENV'] = 'test'

require 'interfaces/web'
def app
  Sinatra::Application
end

require 'rack/test'
include Rack::Test::Methods
