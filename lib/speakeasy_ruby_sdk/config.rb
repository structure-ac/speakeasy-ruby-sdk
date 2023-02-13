module SpeakeasyRubySdk
  class Middleware
    class Config
      attr_accessor :ingestion_server_url, :speakeasy_version, :api_key, :api_id, :version_id, :routes, :masking, :max_capture_size
      @@max_id_size = 128
      @@valid_char_re = /[^a-zA-Z0-9.\-_~]/

      def self.default
        c = Config.new
        c.ingestion_server_url = "grpc.prod.speakeasyapi.dev:443"
        c.speakeasy_version = "1.5.0"
        c.max_capture_size = 1 * 1024 * 1024
        c
      end

      def validate
        errors = []
        if self.api_key.nil? || self.api_key.empty?
          errors << "`api_key` is required"
        end

        if self.api_id.nil? || self.api_id.empty?
          errors << "`api_id` is required"
        end

        if !self.api_id.nil? && self.api_id.length > @@max_id_size
          errors << "`api_id` is too long. Max length is #{@@max_id_size}"
        end

        if !self.api_id.nil? && @@valid_char_re.match(self.api_id)
          errors << "`api_id` contains invalid characters."
        end

        if self.version_id.nil? || self.version_id.empty?
          errors << "`version_id` is required"
        end

        if !self.version_id.nil? && self.version_id.length > @@max_id_size
          errors << "`version_id` is too long. Max length is #{@@max_id_size}"
        end

        if !self.version_id.nil? && @@valid_char_re.match(self.version_id)
          errors << "`version_id` contains invalid characters."
        end

        errors
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