module SpeakeasyRubySdk
  module HarBuilder

    def self.construct_creator name, version
      return {
        "name": name,
        "version": version
      }
    end

    def self.construct_log version, creator, entries, comment
      return {
        'log': {
          "version": version,
          "creator": creator,
          "entries": entries,
          "comment": comment
        }
      }
    end


    def self.construct_empty_cache
      return {
      }
    end
    def self.construct_empty_params
      return []
    end

    def self.construct_query_records query_params
      query_params.map {|k, v| {
        "name": k,
        "value": v
      } }.sort_by(&lambda{ |h| h[:name] })
    end

    def self.construct_response_cookies cookies
      if cookies.present?
        return cookies.map{ |cookie|
          {
            'name': cookie.name,
            'value': cookie.value,
            'path': cookie.path,
            'domain': cookie.domain,
            'expires': cookie.expires,
            'httpOnly': cookie.httponly,
            'secure': cookie.secure
          }
        }
      else
        return []
      end
    end

    def self.construct_request_cookies cookies
      if cookies.present?
        return cookies.map{ |cookie|
          {
            'name': cookie[0],
            'value': cookie[1]
          }
        }
      else
        return []
      end
    end

    def self.construct_header_records headers
      headers.map {|k, v| {
        "name": k,
        "value": v
      } }.sort_by(&lambda{ |h| h[:name] })
    end

    def self.construct_post_data body, headers
      content_type = headers['Content-Type']
      if content_type.blank?
        # TODO Mimetype detection - open question
        content_type = "application.octet-stream"
      end
      return {
        "mimeType": content_type,
        "params": self.construct_empty_params,
        "text": body
      }
    end
    def self.construct_response_content body, headers
      content_type = headers['Content-Type']
      if content_type.blank?
        # TODO Mimetype detection - open question
        content_type = "application.octet-stream"
      end
      ## TODO handle streaming bodies?
      return {
        "mimeType": content_type,
        "text": body,
        "size": body.bytesize
      }
    end

    def self.construct_request request
      return {
        "method": request.method,
        "url": request.url.path, ## Should this be the full url?
        "httpVersion": request.transaction.protocol,
        "cookies": self.construct_request_cookies(request.cookies),
        "headers": self.construct_header_records(request.headers),
        "queryString": self.construct_query_records(request.query_params),
        "postData":    self.construct_post_data(request.body, request.headers),
        "headersSize": request.headers.to_s.bytesize, # TODO - how is this calculated?
        "bodySize": request.body.bytesize, ## TODO - double check this too.
      }
    end

    def self.construct_response response
      ## TODO handle status not being an int?
      return {
        "status": response.status,
        "statusText":  Rack::Utils::HTTP_STATUS_CODES[response.status],
        "httpVersion":  response.transaction.protocol,
        "cookies":  self.construct_response_cookies(response.cookies),
        "headers":  self.construct_header_records(response.headers),
        "content":  self.construct_response_content(response.body, response.headers),
        "redirectURL":  response.headers.fetch('Location', ''),
        "headersSize": response.headers.to_s.bytesize,
        "bodySize":  response.body.bytesize, # TODO - bodysize vs content size. see go sdk
      }
    end

    def self.construct_timings
      # These fiends are requiered, but we don't have broswer data
      # with which to populate them. Hence the -1 static values
      return {
        "send": -1,
        "wait": -1,
        "receive": -1,
      }
    end

    def self.time_difference_ms end_time, start_time
      #TODO put this somewhere more appropriate
      ((end_time - start_time) * 1000.0).to_i
    end
    
    def self.construct_entries http_transaction
      return [{
        "startedDateTime": http_transaction.start_time.iso8601,
        "time": self.time_difference_ms(Time.now, http_transaction.start_time),
        "request": self.construct_request(http_transaction.request),
        "response": self.construct_response(http_transaction.response),
        "connection": http_transaction.request.url.port.to_s,
        "serverIPAddress": http_transaction.request.url.hostname,
        "cache": self.construct_empty_cache,
        "timings": self.construct_timings
      }]
    end

    def self.construct_har http_transaction
      creator = construct_creator SpeakeasyRubySdk.to_s, SpeakeasyRubySdk::VERSION
      version = "1.2"
      comment = "request capture for #{http_transaction.request.url.to_s}"

      entries = construct_entries http_transaction

      log = construct_log version, creator, entries, comment
      log.to_json
    end
  end
end
