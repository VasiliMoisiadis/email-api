ENV['RAILS_ENV'] ||= 'test'

require 'rack/test'
require_relative 'minitest_helper'
require 'mocha/minitest'

require_relative '../lib/email_api'
require_relative '../lib/email_api/email/client/mailgun_client'
require_relative '../lib/email_api/email/client/sendgrid_client'
require_relative '../lib/email_api/email/data/client_response'

# Exclusively tests the Email API. Tests both simulated and live responses.
class EmailApiTests < MiniTest::Test
  include Rack::Test::Methods

  # OK Response Code used by the email clients
  def ok_code
    assert_equal SendgridClient.ok_code, MailgunClient.ok_code
    SendgridClient.ok_code
  end

  # BAD REQUEST Response Code used by the email clients
  def bad_req_code
    assert_equal SendgridClient.bad_req_code, MailgunClient.bad_req_code
    SendgridClient.bad_req_code
  end

  # INTERNAL SERVER ERROR Response Code used by the email clients
  def internal_err_code
    assert_equal SendgridClient.internal_err_code, MailgunClient.internal_err_code
    SendgridClient.internal_err_code
  end

  # Test ping request
  def test_ping
    # Check ping by confirming response is between two times
    time_before = Time.at(Time.now.utc.to_i)
    response    = browser_response 'get', '/ping'
    time_after  = Time.at(Time.now.utc.to_i)

    assert response.respond_to?(:[])
    assert response.key?('time')
    response_time = Time.at(Time.parse(response['time']).to_i)

    assert time_before.utc <= response_time.utc
    assert response_time.utc <= time_after.utc
  end

  # Test simulated api handling nil inputs
  def test_api_handles_nil_input
    mock_clients bad_req_code, bad_req_code

    assert_equal expected_response(bad_req_code), ambiguous_request(nil)
  end

  # Test simulated api handling unsupported inputs
  def test_api_handles_unsupported_input
    mock_clients bad_req_code, bad_req_code

    assert_equal expected_response(bad_req_code), ambiguous_request('text')
    assert_raises NoMethodError do
      ambiguous_request(123)
    end
    assert_raises NoMethodError do
      ambiguous_request([])
    end
  end

  # Test simulated api handling empty inputs
  def test_api_handles_empty_input
    mock_clients bad_req_code, bad_req_code

    assert_equal expected_response(bad_req_code), ambiguous_request({})
    assert_equal expected_response(bad_req_code), ambiguous_request('')
  end

  # Test simulated api handling partial expected inputs
  def test_api_handles_some_input
    mock_clients
    text = 'Text'

    request_hash            = {}
    request_hash['from']    = text
    request_hash['to']      = text
    request_hash['subject'] = text
    request_hash['content'] = text

    expected_hash            = {}
    expected_hash['from']    = EmailAddress.new(text)
    expected_hash['to']      = [EmailAddress.new(text)]
    expected_hash['subject'] = text
    expected_hash['content'] = text

    assert_equal expected_response(ok_code, expected_hash), ambiguous_request(request_hash)
  end

  # Test simulated api handling all expected inputs
  def test_api_handles_all_input
    mock_clients
    text = 'Text'

    request_hash            = {}
    request_hash['from']    = text
    request_hash['to']      = text
    request_hash['cc']      = text
    request_hash['bcc']     = text
    request_hash['subject'] = text
    request_hash['content'] = text

    expected_hash            = {}
    expected_hash['from']    = EmailAddress.new(text)
    expected_hash['to']      = [EmailAddress.new(text)]
    expected_hash['cc']      = [EmailAddress.new(text)]
    expected_hash['bcc']     = [EmailAddress.new(text)]
    expected_hash['subject'] = text
    expected_hash['content'] = text

    assert_equal expected_response(ok_code, expected_hash), ambiguous_request(request_hash)
  end

  # Test simulated api handling exceptions
  def test_api_handles_exception
    EmailClient.stubs(:send_email).raises(StandardError)

    assert_equal expected_response(internal_err_code), ambiguous_request('')
  end

  # Test simulated api handling all clients returning with a BAD REQUEST
  def test_api_bad_request
    mock_clients bad_req_code, bad_req_code

    assert_equal expected_response(bad_req_code), ambiguous_request('')
  end

  # Test live api handling valid workflow through primary email client
  def test_live_api_primary_ok
    mock_clients nil, bad_req_code
    name  = ENV['TEST_NAME']
    email = ENV['TEST_EMAIL']

    assert !name.nil?
    assert !email.nil?

    email_addr      = EmailAddress.new(name, email)
    email_addr_text = "#{name} <#{email}>"

    request_hash            = {}
    request_hash['from']    = email_addr_text
    request_hash['to']      = email_addr_text
    request_hash['cc']      = email_addr_text
    request_hash['bcc']     = email_addr_text
    request_hash['subject'] = 'Moisiadis Email API Test'
    request_hash['content'] = 'Sent with the Moisiadis Email API using Sendgrid'

    expected_hash            = {}
    expected_hash['from']    = email_addr
    expected_hash['to']      = [email_addr]
    expected_hash['cc']      = [email_addr]
    expected_hash['bcc']     = [email_addr]
    expected_hash['subject'] = request_hash['subject']
    expected_hash['content'] = request_hash['content']

    assert_equal expected_response(ok_code, expected_hash), ambiguous_request(request_hash)
  end

  # Test live api handling valid workflow through secondary email client
  def test_live_api_secondary_ok
    mock_clients bad_req_code, nil
    name  = ENV['TEST_NAME']
    email = ENV['TEST_EMAIL']

    assert !name.nil?
    assert !email.nil?

    email_addr      = EmailAddress.new(name, email)
    email_addr_text = "#{name} <#{email}>"

    request_hash            = {}
    request_hash['from']    = email_addr_text
    request_hash['to']      = email_addr_text
    request_hash['cc']      = email_addr_text
    request_hash['bcc']     = email_addr_text
    request_hash['subject'] = 'Moisiadis Email API Test'
    request_hash['content'] = 'Sent with the Moisiadis Email API using Mailgun'

    expected_hash            = {}
    expected_hash['from']    = email_addr
    expected_hash['to']      = [email_addr]
    expected_hash['cc']      = [email_addr]
    expected_hash['bcc']     = [email_addr]
    expected_hash['subject'] = request_hash['subject']
    expected_hash['content'] = request_hash['content']

    assert_equal expected_response(ok_code, expected_hash), ambiguous_request(request_hash)
  end

  # Test live api handling invalid workflow through primary email client
  def test_live_api_primary_bad_request
    mock_clients nil, bad_req_code
    name  = ENV['TEST_NAME']
    email = ENV['TEST_EMAIL']

    assert !name.nil?
    assert !email.nil?

    email_addr      = EmailAddress.new(name, email)
    email_addr_text = "#{name} <#{email}>"

    request_hash            = {}
    request_hash['from']    = nil
    request_hash['to']      = email_addr_text
    request_hash['cc']      = email_addr_text
    request_hash['bcc']     = email_addr_text
    request_hash['subject'] = 'Moisiadis Email API Test'
    request_hash['content'] = 'Sent with the Moisiadis Email API using Sendgrid'

    expected_hash            = {}
    expected_hash['from']    = nil
    expected_hash['to']      = [email_addr]
    expected_hash['cc']      = [email_addr]
    expected_hash['bcc']     = [email_addr]
    expected_hash['subject'] = request_hash['subject']
    expected_hash['content'] = request_hash['content']

    assert_equal expected_response(bad_req_code, expected_hash), ambiguous_request(request_hash)
  end

  # Test live api handling invalid workflow through secondary email client
  def test_live_api_secondary_bad_request
    mock_clients bad_req_code, nil
    name  = ENV['TEST_NAME']
    email = ENV['TEST_EMAIL']

    assert !name.nil?
    assert !email.nil?

    email_addr      = EmailAddress.new(name, email)
    email_addr_text = "#{name} <#{email}>"

    request_hash            = {}
    request_hash['from']    = nil
    request_hash['to']      = email_addr_text
    request_hash['cc']      = email_addr_text
    request_hash['bcc']     = email_addr_text
    request_hash['subject'] = 'Moisiadis Email API Test'
    request_hash['content'] = 'Sent with the Moisiadis Email API using Mailgun'

    expected_hash            = {}
    expected_hash['from']    = nil
    expected_hash['to']      = [email_addr]
    expected_hash['cc']      = [email_addr]
    expected_hash['bcc']     = [email_addr]
    expected_hash['subject'] = request_hash['subject']
    expected_hash['content'] = request_hash['content']

    assert_equal expected_response(bad_req_code, expected_hash), ambiguous_request(request_hash)
  end

  # Initialises mocking of Email Clients
  def mock_clients(primary_exp_code = ok_code, secondary_exp_code = ok_code)
    SendgridClient.stubs(:send_email).returns(primary_exp_code) unless primary_exp_code.nil?
    MailgunClient.stubs(:send_email).returns(secondary_exp_code) unless secondary_exp_code.nil?
  end

  # Simulates both GET and POST browser requests
  def ambiguous_request(params)
    response_get  = browser_response 'get', '/send', params
    response_post = browser_response 'post', '/send', params
    assert_equal response_get, response_post

    # For simplicity, test onward with a single 'response' var
    response = response_get
    validate_response response
    response
  end

  # Simulates a browser request
  def browser_response(request_type, path, params = {})
    browser = Rack::Test::Session.new(Rack::MockSession.new(EmailApi))
    browser.send request_type, path, params
    assert browser.last_response.ok?
    JSON.parse(browser.last_response.body)
  end

  # Builds a testable hash representing the expected response
  def expected_response(response_code = 100, expected_data = {})
    client_response = ClientResponse.new

    # Assign email values
    expected_data.each do |key, value|
      val_hash = value.to_hash if value.respond_to?(:to_hash)
      client_response.email.send("#{key}=", val_hash.nil? ? value : val_hash)
    end

    # Determine if status is successful
    if response_code == ok_code
      client_response.set_ok
    elsif response_code == bad_req_code
      client_response.set_bad_req
    elsif response_code == internal_err_code
      client_response.set_internal_err
    end

    client_response.to_hash
  end

  # Validates the browser response received
  def validate_response(response)
    assert response.respond_to?(:[])
    assert response.key?('status')
    assert response.key?('email')
    assert response['email'].key?('from')
    assert response['email'].key?('to')
    assert response['email'].key?('cc')
    assert response['email'].key?('bcc')
    assert response['email'].key?('subject')
    assert response['email'].key?('content')
  end
end
