module SpeakeasyRubySdk
  class Middleware
    class Config
      attr_accessor :ingestion_server_url, :speakeasy_version, :api_key, :api_id, :version_id, :routes, :masking

      def self.default
        c = Config.new
        c.ingestion_server_url = "grpc.prod.speakeasyapi.dev:443"
        c.speakeasy_version = "1.5.0"
        c
      end

      def merge(config)
        if config
          if config.class == Hash
            config.each { |k, v| instance_variable_set "@#{k}", v }
          end
        end
        self
      end

    end
  end
end