require_relative 'speakeasy_ruby_sdk/version'
require_relative 'speakeasy_ruby_sdk/config'
require_relative 'speakeasy_ruby_sdk/url_utils'
require_relative 'speakeasy_ruby_sdk/masker'
require_relative 'speakeasy_ruby_sdk/http_transaction'
require_relative 'speakeasy_ruby_sdk/har_builder'

require "delegate"

require 'speakeasy_pb'
include Ingest

module SpeakeasyRubySdk
  class RouteWrapper < SimpleDelegator
    def endpoint
      app.dispatcher? ? "#{controller}##{action}" : rack_app.inspect
    end

    def constraints
      requirements.except(:controller, :action)
    end

    def rack_app
      app.rack_app
    end

    def path
      super.spec.to_s
    end

    def name
      super.to_s
    end

    def reqs
      @reqs ||= begin
        reqs = endpoint
        reqs += " #{constraints}" unless constraints.empty?
        reqs
      end
    end

    def controller
      parts.include?(:controller) ? ":controller" : requirements[:controller]
    end

    def action
      parts.include?(:action) ? ":action" : requirements[:action]
    end

    def internal?
      internal
    end

    def engine?
      app.engine?
    end
  end

  class Middleware
    attr_reader :config

    def initialize(app, config=nil)
      @config = Config.default.merge config
      @app = app
      @masker = SpeakeasyRubySdk::Masker.new @config
    end
   
    def call(env)
      start_time = Time.now
      puts 'Middleware reporting in!'
      puts "Server url #{@config.ingestion_server_url} #{@config.speakeasy_version}"

      status, response_headers, response_body = @app.call(env)

      http_request = HttpTransaction.new start_time, env, status, response_headers, response_body, @masker

      path_hint = ''
      if @config.routes
        req = ActionDispatch::Request.new(env)
        found_route = nil
        @config.routes.router.recognize(req) do |route, params|
          found_route = route
        end
        if ! found_route.nil?
          path_hint = RouteWrapper.new(found_route).path
        end
      end
 
      har = HarBuilder.construct_har http_request
      pp har

      credentials = GRPC::Core::ChannelCredentials.new()
      @ingest_client = Ingest::IngestService::Stub.new(@config.ingestion_server_url, credentials)

      request = Ingest::IngestRequest.new
      request.api_id = @config.api_id
      request.path_hint = path_hint
      request.version_id = @config.version_id
      if env.include? :customer_id
        request.customer_id = env[:customer_id].to_s
      end
      request.har = har

      metadata = {"x-api-key": @config.api_key}
      response = @ingest_client.ingest(request, metadata: metadata)


      [status, response_headers, response_body]
    end
  end
end