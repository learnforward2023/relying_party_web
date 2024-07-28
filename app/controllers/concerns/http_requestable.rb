# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

module HttpRequestable
  def post_request(url, body, headers = {})
    uri = URI.parse(url)
    request = Net::HTTP::Post.new(uri)
    request.set_form_data(body)
    headers.each do |key, value|
      request[key] = value
    end

    response = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(request)
    end

    JSON.parse(response.body)
  end

  def get_request(url)
    uri = URI.parse(url)
    response = Net::HTTP.get_response(uri)
    JSON.parse(response.body)
  end
end
