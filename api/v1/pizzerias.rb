require 'sinatra'
require 'sinatra/namespace'
require 'sinatra/cross_origin'
require 'json'

class API < Sinatra::Base

configure do
  register Sinatra::Namespace
  register Sinatra::CrossOrigin
end

enable :cross_origin

namespace '/api' do
  namespace '/v1' do

    get '/pizzerias' do
      content_type :json
      geojson_data['features'].to_json
    end

    get '/pizzerias/:id' do
      content_type :json
      id = params[:id].to_i - 1
      json = geojson_data['features'][id].to_json
      if json == 'null'
        raise Sinatra::NotFound
      else
        json
      end
    end

    get '/properties/search' do
      content_type :json
      @query = params.keys.first
      @pizzerias = geojson_data['features']

      valid_query? ? return_search_results.to_json : []
    end

  end
end

private
  def geojson_data
    JSON.parse(File.read('pizza_map.geojson'))
  end

  def valid_query?
    @pizzerias.any?{|pizzeria| pizzeria['properties'].has_key?(@query)}
  end
  
  def return_search_results
    @pizzerias.select{ |pizzeria| pizzeria['properties'][@query].downcase == params[@query].downcase}
  end
end