require 'uri'
module SpeakeasyRubySdk
  module UrlUtils
    def self.resolve_url env, query_params=nil
      ## TODO: handle Forwarded headers
      
      request_uri = env['REQUEST_URI']
      request_uri = request_uri.split('?')[0]
      scheme = env['rack.url_scheme']
      host = env['HTTP_HOST']
      if query_params
        updated_query_string = URI.encode_www_form query_params
        URI("#{scheme}://#{host}#{request_uri}?#{updated_query_string}")
      else 
        URI("#{scheme}://#{host}#{request_uri}")
      end
    end
  end
end