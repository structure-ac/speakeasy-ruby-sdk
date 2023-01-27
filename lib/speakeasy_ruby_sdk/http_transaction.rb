require 'http-cookie'

module SpeakeasyRubySdk
  class HttpTransaction
    attr_accessor :status, :env, :request, :response
    def initialize env, status, response_headers, response_body
      @status = status
      @env = env

      ## TODO - Content-Type and Content-Length request headers are not handled
      ## consistently, and my initial research couldn't expose them.
      
      # normalize request headers
      request_headers = Hash[*env.select {|k,v| k.start_with? 'HTTP_'}
        .collect {|k,v| [k.sub(/^HTTP_/, ''), v]}
        .collect {|k,v| [k.split('_').collect(&:capitalize).join('-'), v]}
        .sort
        .flatten]
      request_body = env['rack.input'].read

      query_params = Rack::Utils.parse_nested_query(env['QUERY_STRING'])
      request_url = UrlUtils.resolve_url env, request_headers, query_params

      request_cookies = CGI::Cookie.parse(request_headers['Cookie'] || '').map {|cookie| [cookie[0], cookie[1][0]] }
      response_cookies = HTTP::Cookie.parse(response_headers['Set-Cookie'] || '', request_url)


      @request = HttpRequest.new request_url, request_headers, query_params, request_body, request_cookies
      @response = HttpResponse.new response_headers, response_body, response_cookies
    end
  end

  class HttpRequest
    attr_accessor :request_url, :query_params, :request_headers, :request_body, :request_cookies
    def initialize request_url, request_headers, query_params, request_body, request_cookies
      @request_url = request_url
      @query_params = query_params
      @request_headers = request_headers
      @request_body = request_body
      @request_cookies = request_cookies
    end
  end

  class HttpResponse
    attr_accessor :response_headers, :response_body, :response_cookies
    def initialize response_headers, response_body, response_cookies
      @response_headers = response_headers
      @response_body = response_body
      @response_cookies = response_cookies
    end
  end
end

