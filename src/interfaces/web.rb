require 'sinatra'
require 'sinatra/json'
require 'faker'
require 'active_support'

def error_resp
  status 200
  content_type :json
  { module: '', method: '', data: [] }.to_json
end

get '/?' do
  'API interface for https:://github.com/stympy/faker gem'
end

get '/faker/*?' do
  begin
    content_type :json

    possible_class, possible_method = params[:splat].first.split('/')

    clazz = faker_class_for(possible_class)
    method = faker_method_for(clazz, possible_method)

    data = faker_data_times(clazz, method, params[:count] ? params[:count].to_i : 1)

    { module: clazz, method: method, data: data }.to_json
  rescue
    error_resp
  end
end


def faker_class_for(possible_class)
  if possible_class =~ /s$/
    begin
      Object.const_get(['Faker', possible_class.capitalize].join('::'))
    rescue
      Object.const_get(['Faker', possible_class.gsub(/s$/, '').capitalize].join('::'))
    end
  else
    begin
      Object.const_get(['Faker', possible_class.gsub(/s$/, '').capitalize].join('::'))
    rescue
      Object.const_get(['Faker', (possible_class + 's').capitalize].join('::'))
    end
  end
end

def faker_method_for(clazz, method)
  return method if clazz.respond_to?(method)
  method.gsub(/s$/, '')
end

def faker_data_times(clazz, method, count)
  return [] if count == 0
  count.times.map { clazz.send(method) }
end
