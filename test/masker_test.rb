require 'test/unit'
require 'rack/test'
require 'json'
require_relative '../lib/speakeasy_ruby_sdk'

class MaskerTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def self.init_masker config
    config = SpeakeasyRubySdk::Middleware::Config.default.merge config
    SpeakeasyRubySdk::Masker.new config
  end

  def test_mask_query_param_simple
    masker_config = {
      routes: nil,
      masking: {
        query_params: {
          attributes: ['carrot'],
        }
      }
    }
    masker = MaskerTest::init_masker(masker_config)

    query_params = {'carrot': 'stick', 'parsnip': 'triangular'}

    masked_params = masker.mask_query_params '', query_params

    assert_equal(SpeakeasyRubySdk::Masker::SIMPLE_MASK, masked_params[:carrot])
    assert_equal(query_params[:parsnip], masked_params[:parsnip]) # Should be unchanged
  end
  def test_mask_query_param_multiple_attrs
    masker_config = {
      routes: nil,
      masking: {
        query_params: {
          attributes: ['carrot', 'parsnip', 'unknown'],
        }
      }
    }
    masker = MaskerTest::init_masker(masker_config)

    query_params = {'carrot': 'stick', 'parsnip': 'triangular'}

    masked_params = masker.mask_query_params '', query_params

    assert_equal(SpeakeasyRubySdk::Masker::SIMPLE_MASK, masked_params[:carrot])
    assert_equal(SpeakeasyRubySdk::Masker::SIMPLE_MASK, masked_params[:parsnip])
  end

  def test_mask_query_param_custom_mask
    masker_config = {
      routes: nil,
      masking: {
        query_params: {
          attributes: ['carrot'],
          value: "_MASK_"
        }
      }
    }
    masker = MaskerTest::init_masker(masker_config)

    query_params = {'carrot': 'stick', 'parsnip': 'triangular'}

    masked_params = masker.mask_query_params '', query_params

    assert_equal("_MASK_", masked_params[:carrot])
    assert_equal(query_params[:parsnip], masked_params[:parsnip]) # Should be unchanged
  end


  def test_mask_response_cookies_simple
    masker_config = {
      masking: {
        response_cookies: {
          attributes: ['magic']
        }
      }
    }
    masker = MaskerTest::init_masker(masker_config)

    response_cookies = HTTP::Cookie.parse("magic=itsnotmagic; path=/; max-age=86400; SameSite=Lax", 'http://localhost:8000')
    
    masked_cookies = masker.mask_response_cookies '', response_cookies
    
    first_cookie = masked_cookies[0]

    assert_equal(SpeakeasyRubySdk::Masker::SIMPLE_MASK, first_cookie.value)
    # assert_equal(query_params[:parsnip], masked_params[:parsnip]) # Should be unchanged

  end

  def test_mask_body_string_simple
    masker_config = {
      masking: {
        mask_body_string: {
          attributes: ['sign_in']
        }
      }
    }
    masker = MaskerTest::init_masker(masker_config)

    body = {
      'sign_in': 'wiley',
      'nobody': 'somebody'
  }.to_json
    masked_body = masker.mask_body('', body)
    assert !masked_body.include?('wiley')
    assert masked_body.include?('somebody')
  end

  def test_mask_body_number_simple
    masker_config = {
      masking: {
        mask_body_number: {
          attributes: ['sign_in']
        }
      }
    }
    masker = MaskerTest::init_masker(masker_config)

    body = {
      'sign_in': 5476,
      'nobody': 'somebody'
    }.to_json
    masked_body = masker.mask_body('', body)
    assert ! masked_body.include?('5476')
    assert masked_body.include?('somebody')
  end

  def test_mask_body_number_and_string
    masker_config = {
      masking: {
        mask_body_number: {
          attributes: ['attr1']
        },
        mask_body_string: {
          attributes: ['attr2']
        }
      }
    }
    masker = MaskerTest::init_masker(masker_config)

    body = {
      'attr1': 5476,
      'attr2': 'somebody',
      'attr3': 'keep it'
    }.to_json
    masked_body = masker.mask_body('', body)
    assert !masked_body.include?('5476')
    assert !masked_body.include?('somebody')
    assert masked_body.include?('keep it')
  end
end
