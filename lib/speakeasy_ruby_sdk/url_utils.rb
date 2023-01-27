require 'uri'
module SpeakeasyRubySdk
  module UrlUtils
    def self.resolve_url env, headers, query_params
      ## TODO: handle Forwarded headers
      
      request_uri = env['REQUEST_URI']
      scheme = env['rack.url_scheme']
      host = env['HTTP_HOST']

      updated_query_string = URI.encode_www_form query_params

      URI("#{scheme}://#{host}#{request_uri}#{updated_query_string}")
    end
  end
end