module SpeakeasyRubySdk
  module HarBuilder

    def self.construct_creator name, version
      return {
        "name": name,
        "version": version
      }
    end

    def self.construct_log version, creator, comment
      return {
        'log': {
          "version": version,
          "creator": creator,
          "comment": comment
        }
      }
    end

    def self.construct_har http_transaction
      creator = construct_creator SpeakeasyRubySdk.to_s, SpeakeasyRubySdk::VERSION
      version = "1.2"
      comment = "request capture for #{http_transaction.request.request_url.to_s}"

      log = construct_log version, creator, comment
      log.to_json
    end
  end
end
