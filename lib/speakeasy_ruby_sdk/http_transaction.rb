require 'http-cookie'

module SpeakeasyRubySdk
  class HttpTransaction

    attr_reader :time_utils, :status, :env, :request, :response, :protocol, :port

    def initialize time_utils, env, status, response_headers, response_body, masker
      ## Setup Data
      @time_utils = time_utils
      @status = status
      @env = env
      @protocol = env['SERVER_PROTOCOL']
      @port = env['SERVER_PORT']

      # normalize request headers
      request_headers = Hash[*env.select {|k,v| k.start_with? 'HTTP_'}
        .collect {|k,v| [k.sub(/^HTTP_/, ''), v]}
        .collect {|k,v| [k.split('_').collect(&:downcase).join('-'), v]}
        .sort
        .flatten]
      request_body = env['rack.input'].read
      request_method = env['REQUEST_METHOD']
      rack_request = Rack::Request.new(env)
      response_headers = Hash[response_headers.collect {|k,v| [k.downcase, v] }]
      scheme = self.handle_forward_headers request_headers
      if scheme
        @protocol = scheme
      end
      query_params = Rack::Utils.parse_nested_query(env['QUERY_STRING'])

      ## Temporary url var for populating cookiejar.
      unmasked_url = UrlUtils.resolve_url env

      request_cookies = CGI::Cookie.parse(request_headers['cookie'] || '').map { |cookie| [cookie[0], cookie[1][0]] }
      response_cookies = HTTP::CookieJar.new()
      if response_headers.include? 'set-cookie'
        cookies = response_headers['set-cookie']
        cookies.map { |cookie| response_cookies.parse(cookie, unmasked_url) }
      end

      ## Begin Masking
      masked_query_params = masker.mask_query_params unmasked_url.path, query_params
      
      masked_request_headers = masker.mask_request_headers unmasked_url.path, request_headers
      masked_response_headers = masker.mask_response_headers unmasked_url.path, response_headers

      request_url = UrlUtils.resolve_url env, masked_query_params

      masked_request_cookies = masker.mask_request_cookies unmasked_url.path, request_cookies
      masked_response_cookies = masker.mask_response_cookies unmasked_url.path, response_cookies

      masked_request_body = masker.mask_request_body unmasked_url.path, request_body
      masked_response_body = masker.mask_response_body unmasked_url.path, response_body


      ## Construct Request Response
      @request = HttpRequest.new self, rack_request, request_url, request_method, masked_request_headers, masked_query_params, masked_request_body, masked_request_cookies
      @response = HttpResponse.new self, status, masked_response_headers, masked_response_body, masked_response_cookies
    end
  end

  class HttpRequest
    attr_reader :transaction, :method, :url, :query_params, :headers, :body, :cookies
    def initialize transaction, rack_request, request_url, request_method, request_headers, query_params, request_body, request_cookies
      @transaction = transaction
      @rack_request = rack_request
      @url = request_url
      @query_params = query_params
      @method = request_method
      @headers = request_headers
      @body = request_body
      @cookies = request_cookies
    end

    def content_type
      @rack_request.content_type
    end

    def content_length
      if @rack_request.content_length == "0"
        -1
      else
        @rack_request.content_length
      end
    end
  end

  class HttpResponse
    attr_reader :transaction, :status, :headers, :body, :cookies
    def initialize transaction, status, response_headers, response_body, response_cookies
      @transaction = transaction
      @status = (status.nil? || status == -1) ? 200 : status
      @headers = response_headers
      @body = response_body
      @cookies = response_cookies
    end
  end
end
