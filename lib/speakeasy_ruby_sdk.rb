require_relative 'speakeasy_ruby_sdk/version'
require_relative 'speakeasy_ruby_sdk/config'
require_relative 'speakeasy_ruby_sdk/url_utils'

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

      status, headers, response_body = @app.call(env)

      ## TODO - Content-Type and Content-Length request headers are not handled
      ## consistently, and my initial research couldn't expose them.
      request_headers = Hash[*env.select {|k,v| k.start_with? 'HTTP_'}
        .collect {|k,v| [k.sub(/^HTTP_/, ''), v]}
        .collect {|k,v| [k.split('_').collect(&:capitalize).join('-'), v]}
        .sort
        .flatten]
      response_headers = headers
      request_body = env['rack.input'].read

      query_params = Rack::Utils.parse_nested_query(env['QUERY_STRING'])
      request_url = SpeakeasyRubySdk::UrlUtils.resolve_url env, request_headers, query_params

      [status, headers, response_body]
    end
  end
end