require 'test/unit'
require 'rack/test'
require 'json'
require_relative '../lib/speakeasy_ruby_sdk'
class BasicHttpTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    ->(_env) { [200, { 'content-type' => 'text/javascript' }, ['All responses are OK']] }
  end

  def test_response_is_unchanged
    request = Rack::MockRequest.env_for('/', method: :get)

    subject = SpeakeasyRubySdk::Middleware.new(app)
    status, _headers, _response = subject.call(request)
    assert_equal status, 200
  end
end
