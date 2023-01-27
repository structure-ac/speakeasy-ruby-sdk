require 'speakeasy_ruby_sdk/version'
require 'speakeasy_ruby_sdk/config'

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

      [status, headers, response_body]
    end
  end
end