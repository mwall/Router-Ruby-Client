require 'net/http'
require 'ostruct'
require 'json'

class Conflict < RuntimeError
end

class RouterClient

  def initialize(base_url)
    @base_url = base_url
  end

  def create_application(application_id, backend_url)
    response post "/applications/#{application_id}", {'backend_url' => backend_url}
  end

  def get_application(application_id)
    response get "/applications/#{application_id}"
  end

  private
  def router_url(uri)
    URI.parse(@base_url + uri)
  end

  def post(uri, params)
    Net::HTTP.post_form(router_url(uri), params)
  end

  def get(uri)
    Net::HTTP.get(router_url uri)
  end

  def response(response)
    case response
      when Net::HTTPConflict
        raise Conflict
      when String
        to_ostruct JSON.parse(response)
      else
        to_ostruct JSON.parse(response.body)
    end
  end

  def to_ostruct(json)
    case json
      when Hash
        values = {}
        json.each { |key, value| values[key] = to_ostruct(value) }
        OpenStruct.new(values)
      else
        json
    end
  end
end


