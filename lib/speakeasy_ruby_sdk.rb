require_relative 'speakeasy_ruby_sdk/version'
require_relative 'speakeasy_ruby_sdk/config'
require_relative 'speakeasy_ruby_sdk/url_utils'
require_relative 'speakeasy_ruby_sdk/http_transaction'
require_relative 'speakeasy_ruby_sdk/har_builder'

module SpeakeasyRubySdk
  class Middleware
    attr_reader :config

    def initialize(app, config=nil)
      @config = Middleware::Config.default.merge config
      @app = app
    end
   
    def call(env)
      puts 'Middleware reporting in!'
      puts "Server url #{@config.ingestion_server_url} #{@config.speakeasy_version}"

      status, response_headers, response_body = @app.call(env)

      ## TODO - Content-Type and Content-Length request headers are not handled
      ## consistently, and my initial research couldn't expose them.
      request_headers = Hash[*env.select {|k,v| k.start_with? 'HTTP_'}
        .collect {|k,v| [k.sub(/^HTTP_/, ''), v]}
        .collect {|k,v| [k.split('_').collect(&:capitalize).join('-'), v]}
        .sort
        .flatten]
      request_body = env['rack.input'].read

      query_params = Rack::Utils.parse_nested_query(env['QUERY_STRING'])
      request_url = UrlUtils.resolve_url env, request_headers, query_params

      http_request = HttpTransaction.new status, env, request_url, request_headers, response_headers, query_params, request_body, response_body

      har = HarBuilder.construct_har http_request

      [status, response_headers, response_body]
    end
  end
end