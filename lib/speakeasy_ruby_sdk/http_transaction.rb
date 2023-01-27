
module SpeakeasyRubySdk
  class HttpTransaction
    attr_accessor :status, :env, :request, :response
    def initialize status, env, request_headers, response_headers, query_params, request_body, response_body
      @status = status
      @env = env
      @request = HttpRequest.new request_headers, query_params, request_body
      @response = HttpResponse.new response_headers, response_body
    end
  end

  class HttpRequest
    attr_accessor :query_params, :request_headers, :request_body
    def initialize request_headers, query_params, request_body
      @query_params = query_params
      @request_headers = request_headers
      @request_body = request_body
    end
  end

  class HttpResponse
    attr_accessor :response_headers, :response_body
    def initialize response_headers, response_body
      @response_headers = response_headers
      @response_body = response_body
    end
  end
end

