require 'http-cookie'

module SpeakeasyRubySdk
  class HttpTransaction
    attr_reader :start_time, :status, :env, :request, :response, :protocol
    def initialize start_time, env, status, response_headers, response_body
      @start_time = start_time
      @status = status
      @env = env
      @protocol = env['SERVER_PROTOCOL']
      ## TODO - Content-Type and Content-Length request headers are not handled
      ## consistently, and my initial research couldn't expose them.
      
      # normalize request headers
      request_headers = Hash[*env.select {|k,v| k.start_with? 'HTTP_'}
        .collect {|k,v| [k.sub(/^HTTP_/, ''), v]}
        .collect {|k,v| [k.split('_').collect(&:capitalize).join('-'), v]}
        .sort
        .flatten]
      request_body = env['rack.input'].read
      request_method = env['REQUEST_METHOD']

      query_params = Rack::Utils.parse_nested_query(env['QUERY_STRING'])
      request_url = UrlUtils.resolve_url env, request_headers, query_params

      request_cookies = CGI::Cookie.parse(request_headers['Cookie'] || '').map {|cookie| [cookie[0], cookie[1][0]] }
      response_cookies = HTTP::Cookie.parse(response_headers['Set-Cookie'] || '', request_url)

      @request = HttpRequest.new self, request_url, request_method, request_headers, query_params, request_body, request_cookies
      @response = HttpResponse.new self, status, response_headers, response_body, response_cookies
    end
  end

  class HttpRequest
    attr_reader :transaction, :method, :url, :query_params, :headers, :body, :cookies
    def initialize transaction, request_url, request_method, request_headers, query_params, request_body, request_cookies
      @transaction = transaction
      @url = request_url
      @query_params = query_params
      @method = request_method
      @headers = request_headers
      @body = request_body
      @cookies = request_cookies
    end
  end

  class HttpResponse
    attr_reader :transaction, :status, :headers, :body, :cookies
    def initialize transaction, status, response_headers, response_body, response_cookies
      @transaction = transaction
      @status = status
      @headers = response_headers
      @body = response_body.present? ? response_body.body : ""
      @cookies = response_cookies
    end
  end
end

