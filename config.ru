$:.unshift File.expand_path('src')

require 'interfaces/web'
run Sinatra::Application
