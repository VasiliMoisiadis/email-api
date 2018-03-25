ENV['RAILS_ENV'] ||= 'test'

require 'rack/test'
require_relative '../minitest_helper'
require 'mocha/minitest'
require 'json'

require_relative '../../lib/email_api/email/client/sendgrid_client'
require_relative '../../lib/email_api/email/data/email_address'

# Exclusively tests the Sendgrid Email Client
class SendgridClientTests < MiniTest::Test
  include Rack::Test::Methods

  # OK Response Code used by the email client
  def ok_code
    SendgridClient.ok_code
  end

  # BAD REQUEST Response Code used by the email client
  def bad_req_code
    SendgridClient.bad_req_code
  end

  # INTERNAL SERVER ERROR Response Code used by the email client
  def internal_err_code
    SendgridClient.internal_err_code
  end

  # Expected Message returned by the email client when response is OK
  def exp_msg
    { :'message' => SendgridClient.exp_msg }.to_json
  end

  # Mock message to test unhandled response messages
  def fail_msg
    { :'message' => SendgridClient.exp_msg.reverse }.to_json
  end

  # Test Sendgrid Client handling unsupported inputs
  def test_sg_client_handles_unsupported_input
    RestClient.stubs(:post).returns(exp_msg)
    ENV.stubs(:[]).returns('AN ENV VAR')

    assert_equal bad_req_code, SendgridClient.send_email(nil)
    assert_equal bad_req_code, SendgridClient.send_email('')
    assert_equal bad_req_code, SendgridClient.send_email(123)
    assert_equal bad_req_code, SendgridClient.send_email({})
    assert_equal bad_req_code, SendgridClient.send_email([])
  end

  # Test Sendgrid Client handling empty inputs
  def test_sg_client_empty_input
    RestClient.stubs(:post).returns(exp_msg)
    ENV.stubs(:[]).returns('AN ENV VAR')

    assert_equal bad_req_code, SendgridClient.send_email(EmailObject.new)
  end

  # Test Sendgrid Client handling missing environment variables
  def test_sg_client_missing_env_variables
    RestClient.stubs(:post).returns(exp_msg)
    ENV.stubs(:[]).returns(nil)

    assert_equal internal_err_code, SendgridClient.send_email(EmailObject.new)
  end

  # Test Sendgrid Client handling missing mandatory email attributes
  def test_sg_client_input_missing_mandatory_variables
    RestClient.stubs(:post).returns(exp_msg)
    ENV.stubs(:[]).returns('AN ENV VAR')
    valid_addr = EmailAddress.new ''

    email_obj         = EmailObject.new
    email_obj.from    = nil
    email_obj.to      = [valid_addr]
    email_obj.subject = valid_addr
    email_obj.content = valid_addr
    assert_equal bad_req_code, SendgridClient.send_email(email_obj)

    email_obj         = EmailObject.new
    email_obj.from    = valid_addr
    email_obj.to      = nil
    email_obj.subject = valid_addr
    email_obj.content = valid_addr
    assert_equal bad_req_code, SendgridClient.send_email(email_obj)

    email_obj         = EmailObject.new
    email_obj.from    = valid_addr
    email_obj.to      = [valid_addr]
    email_obj.subject = nil
    email_obj.content = valid_addr
    assert_equal bad_req_code, SendgridClient.send_email(email_obj)

    email_obj         = EmailObject.new
    email_obj.from    = valid_addr
    email_obj.to      = [valid_addr]
    email_obj.subject = valid_addr
    email_obj.content = nil
    assert_equal bad_req_code, SendgridClient.send_email(email_obj)
  end

  # Test Sendgrid Client handling provided mandatory email attributes
  def test_sg_client_input_has_mandatory_variables
    RestClient.stubs(:post).returns(exp_msg)
    ENV.stubs(:[]).returns('AN ENV VAR')
    valid_addr = EmailAddress.new ''

    email_obj         = EmailObject.new
    email_obj.from    = valid_addr
    email_obj.to      = [valid_addr]
    email_obj.subject = valid_addr
    email_obj.content = valid_addr
    assert_equal ok_code, SendgridClient.send_email(email_obj)
  end

  # Test Sendgrid Client handling provided optional email attributes
  def test_sg_client_input_has_optional_variables
    RestClient.stubs(:post).returns(exp_msg)
    ENV.stubs(:[]).returns('AN ENV VAR')
    valid_addr = EmailAddress.new ''

    email_obj         = EmailObject.new
    email_obj.from    = valid_addr
    email_obj.to      = [valid_addr]
    email_obj.cc      = [valid_addr]
    email_obj.bcc     = [valid_addr]
    email_obj.subject = valid_addr
    email_obj.content = valid_addr
    assert_equal ok_code, SendgridClient.send_email(email_obj)
  end

  # Test Sendgrid Client handling provided when response is a BAD REQUEST
  def test_sg_client_request_returns_bad_request
    RestClient.stubs(:post).returns(fail_msg)
    ENV.stubs(:[]).returns('AN ENV VAR')
    valid_addr = EmailAddress.new ''

    email_obj         = EmailObject.new
    email_obj.from    = valid_addr
    email_obj.to      = [valid_addr]
    email_obj.cc      = [valid_addr]
    email_obj.bcc     = [valid_addr]
    email_obj.subject = valid_addr
    email_obj.content = valid_addr
    assert_equal internal_err_code, SendgridClient.send_email(email_obj)
  end

  # Test Sendgrid Client handling provided when response raises exception
  def test_sg_client_request_raises_exception
    RestClient.stubs(:post).raises(StandardError)
    ENV.stubs(:[]).returns('AN ENV VAR')
    valid_addr = EmailAddress.new ''

    email_obj         = EmailObject.new
    email_obj.from    = valid_addr
    email_obj.to      = [valid_addr]
    email_obj.cc      = [valid_addr]
    email_obj.bcc     = [valid_addr]
    email_obj.subject = valid_addr
    email_obj.content = valid_addr
    assert_equal bad_req_code, SendgridClient.send_email(email_obj)
  end

end
