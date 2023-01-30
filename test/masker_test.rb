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

end

