require_relative 'speakeasy_ruby_sdk/version'
require_relative 'speakeasy_ruby_sdk/config'
require_relative 'speakeasy_ruby_sdk/url_utils'
require_relative 'speakeasy_ruby_sdk/masker'
require_relative 'speakeasy_ruby_sdk/http_transaction'
require_relative 'speakeasy_ruby_sdk/har_builder'

require 'speakeasy_pb'
include Ingest

module SpeakeasyRubySdk
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

      har = HarBuilder.construct_har http_request

      credentials = GRPC::Core::ChannelCredentials.new()
      @ingest_client = Ingest::IngestService::Stub.new(@config.ingestion_server_url, credentials)

      request = Ingest::IngestRequest.new
      request.api_id = @config.api_id
      request.path_hint = ''
      request.version_id = @config.version_id
      request.customer_id = ''
      request.har = har
      metadata = {"x-api-key": @config.api_key}
      response = @ingest_client.ingest(request, metadata: metadata)


      [status, response_headers, response_body]
    end
  end
end