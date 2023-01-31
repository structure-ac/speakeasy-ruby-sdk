module SpeakeasyRubySdk
  class Masker

    SIMPLE_MASK = '__masked__'
    SIMPLE_NUMBER_MASK = -12321

    def initialize config
      @routes = config.routes
      @masking = config.masking

      @masking.map{ |key, mask|
        mask[:attributes] = mask[:attributes].map { |attr| attr.downcase }
        }
    end

    def mask_value mask, path, value
      if mask.include? :controller
        route = @routes.recognize_path path
        if mask[:controller] === route[:prefix]
          return mask[:value] || Masker::SIMPLE_MASK
        else
          return value;
        end
      else
        return mask[:value] || Masker::SIMPLE_MASK
      end      
    end

    def mask_pair masking_key, path, key, value
      masked_value = value
      if @masking.include? masking_key
        mask = @masking[masking_key]
        if mask[:attributes].include? key.to_s.downcase
          masked_value = mask_value mask, path, mask[:value]
        end
      end
      return masked_value
    end
    
    def mask_dict masking_key, path, hash_map
      masked_dict = {}
      for key, value in hash_map
        masked_dict[key] = mask_pair masking_key, path, key, value
      end
      masked_dict
    end

    def mask_query_params path, query_params
      mask_dict :query_params, path, query_params
    end

    def mask_request_headers path, headers
      mask_dict :request_headers, path, headers
    end

    def mask_response_headers path, headers
      mask_dict :response_headers, path, headers
    end

    def mask_request_cookies path, cookies
      mask_dict :request_cookies, path, cookies
    end

    def mask_response_cookies path, cookies
      for cookie in cookies
        key = cookie.name
        value = cookie.value
        masked_value = self.mask_pair :response_cookies, path, key, value
        cookie.value = masked_value
      end
      cookies
    end

    def mask_body path, body
      masked_body = body
      if @masking.include? :mask_body_string
        for attribute in @masking[:mask_body_string][:attributes]

          regex_string = Regexp.new "(\"#{attribute}\": *)(\".*?[^\\\\]\")( *[, \\n\\r}]?)"
          
          matches = body.match(regex_string)
          if matches
            masked_body = masked_body.gsub(regex_string, "#{matches[1]}\"#{Masker::SIMPLE_MASK}\"#{matches[3]}")
          end
        end
      end
      if @masking.include? :mask_body_number
        for attribute in @masking[:mask_body_number][:attributes]
          regex_string = Regexp.new "(\"#{attribute}\": *)(-?[0-9]+\\.?[0-9]*)( *[, \\n\\r}]?)"
          matches = body.match(regex_string)
          if matches
            masked_body = masked_body.gsub(regex_string, "#{matches[1]}#{Masker::SIMPLE_MASK}#{matches[3]}")
          end
        end
      end
      masked_body
    end

    def mask_request_body path, body
      mask_body path, body
    end

    def mask_response_body path, body
      mask_body path, body
    end


  end
end


