require 'sinatra'
require 'sinatra/json'
require 'faker'
require 'active_support'

set :cache_enabled, true

get '/?' do
  'API interface for https:://github.com/stympy/faker gem'
end

get '/faker/*?' do
  content_type :json

  mod, method = params[:splat].first.split('/')
  clazz = Object.const_get(['Faker', mod.capitalize].join('::'))

  if params[:count].to_i > 0
    data = params[:count].to_i.times.map { clazz.send(method) }
  else
    data = [clazz.send(method)]
  end

  { module: clazz, method: method, data: data }.to_json
end
