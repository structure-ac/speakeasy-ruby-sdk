module SpeakeasyRubySdk
  class Masker

    SIMPLE_MASK = '[***]'

    def initialize config
      @routes = config.routes
      @masking = config.masking
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

    def mask_query_param path, key, value
      masked_value = value
      for mask in @masking[:query_string]
        if mask[:attributes].include? key.to_s
          masked_value = mask_value mask, path, mask[:value]
        end
      end
      return masked_value
    end

    def mask_query_params path, query_params      
      masked_params = {}
      for k, v in query_params
        masked_params[k] = mask_query_param(path, k, v)
      end
      masked_params
    end

    def mask_headers headers
      # TODO
      headers
    end

    def mask_body body
      # TODO
      body
    end

    def mask_cookie cookie
      # TODO
      cookie
    end


  end
end