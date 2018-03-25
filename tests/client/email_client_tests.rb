ENV['RAILS_ENV'] ||= 'test'

require 'rack/test'
require_relative '../minitest_helper'
require 'mocha/minitest'
require 'json'

require_relative '../../lib/email_api/email/client/email_client'

# Exclusively tests the Email Client
class EmailClientTests < MiniTest::Test
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

  # Test EmailClient handling unsupported inputs
  def test_email_client_handles_unsuported_input
    MailgunClient.stubs(:send_email).returns(ok_code)
    SendgridClient.stubs(:send_email).returns(ok_code)

    assert_equal ClientResponse.new, EmailClient.send_email(nil)
    assert_equal ClientResponse.new, EmailClient.send_email('')
    assert_equal ClientResponse.new, EmailClient.send_email(123)
    assert_equal ClientResponse.new, EmailClient.send_email({})
    assert_equal ClientResponse.new, EmailClient.send_email([])
  end

  # Test EmailClient handling empty text as input
  def test_email_client_empty_input
    MailgunClient.stubs(:send_email).returns(ok_code)
    SendgridClient.stubs(:send_email).returns(ok_code)

    input_val = EmailObject.new
    response  = ClientResponse.new input_val
    response.set_ok

    assert_equal response, EmailClient.send_email(input_val)
  end

  # Test EmailClient handling workflow when all clients return OK
  def test_email_client_all_clients_success
    MailgunClient.stubs(:send_email).returns(ok_code)
    SendgridClient.stubs(:send_email).returns(ok_code)

    input_val = EmailObject.new
    response  = ClientResponse.new input_val
    response.set_ok

    assert_equal response, EmailClient.send_email(input_val)
  end

  # Test EmailClient handling workflow when only Primary Client returns OK
  def test_email_client_primary_success_only
    MailgunClient.stubs(:send_email).returns(ok_code)
    SendgridClient.stubs(:send_email).returns(bad_req_code)

    input_val = EmailObject.new
    response  = ClientResponse.new input_val
    response.set_ok

    assert_equal response, EmailClient.send_email(input_val)
  end

  # Test EmailClient handling workflow when only Secondary Client returns OK
  def test_email_client_secondary_success_only
    MailgunClient.stubs(:send_email).returns(bad_req_code)
    SendgridClient.stubs(:send_email).returns(ok_code)

    input_val = EmailObject.new
    response  = ClientResponse.new input_val
    response.set_ok

    assert_equal response, EmailClient.send_email(input_val)
  end

  # Test EmailClient handling workflow when all email clients returns BAD REQUEST
  def test_email_client_all_clients_bad_request
    MailgunClient.stubs(:send_email).returns(bad_req_code)
    SendgridClient.stubs(:send_email).returns(bad_req_code)

    input_val = EmailObject.new
    response  = ClientResponse.new input_val
    response.set_bad_req

    assert_equal response, EmailClient.send_email(input_val)
  end

  # Test EmailClient handling workflow when all email clients returns INTERNAL
  # SERVER ERROR
  def test_email_client_all_clients_internal_error
    MailgunClient.stubs(:send_email).returns(internal_err_code)
    SendgridClient.stubs(:send_email).returns(internal_err_code)

    input_val = EmailObject.new
    response  = ClientResponse.new input_val
    response.set_internal_err

    assert_equal response, EmailClient.send_email(input_val)
  end

  # Test EmailClient handling workflow when all email clients return an
  # unsupported response code
  def test_email_client_all_clients_undefined_code
    MailgunClient.stubs(:send_email).returns(100)
    SendgridClient.stubs(:send_email).returns(100)

    input_val = EmailObject.new
    response  = ClientResponse.new input_val

    assert_equal response, EmailClient.send_email(input_val)
  end

  # Test EmailClient handling workflow when all email clients raise exceptions
  def test_email_client_all_client_handles_exception
    MailgunClient.stubs(:send_email).raises(StandardError)
    SendgridClient.stubs(:send_email).raises(StandardError)

    input_val = EmailObject.new
    response  = ClientResponse.new input_val
    response.set_internal_err

    assert_equal response, EmailClient.send_email(input_val)
  end
end
