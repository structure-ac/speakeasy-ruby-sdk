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
      start_time = Time.now
      puts 'Middleware reporting in!'
      puts "Server url #{@config.ingestion_server_url} #{@config.speakeasy_version}"

      status, response_headers, response_body = @app.call(env)

      http_request = HttpTransaction.new start_time, env, status, response_headers, response_body

      har = HarBuilder.construct_har http_request

      [status, response_headers, response_body]
    end
  end
end