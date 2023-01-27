require 'speakeasy_ruby_sdk/version'

module SpeakeasyRubySdk
  class Middleware
    def initialize(app)
      @app = app
    end
   
    def call(env)
      puts 'Middleware reporting in!'

      status, headers, response_body = @app.call(env)

      [status, headers, response_body]
    end
  end
end