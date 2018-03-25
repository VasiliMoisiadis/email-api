require './lib/email_api/email/client/mailgun_client'
require './lib/email_api/email/client/sendgrid_client'
require './lib/email_api/email/data/client_response'
require 'json'

# General client that sends email utilizing multiple service providers
class EmailClient

  # Accessor for the OK Code
  def self.ok_code
    200
  end

  # Accessor for the Bad Request Code
  def self.bad_req_code
    400
  end

  # Accessor for the Internal Server Error Code
  def self.internal_err_code
    500
  end

  # Sends email utilizing multiple service providers
  #
  # @param [EmailObject] email_object
  # @return [ClientResponse] response
  def self.send_email(email_object)
    return ClientResponse.new if email_object.nil? || !email_object.is_a?(EmailObject)

    puts 'Attempting Email Sending via primary client: SENDGRID'
    response = use_client_client SendgridClient, email_object

    if response != ok_code
      puts 'Primary client failed. Attempting secondary client: MAILGUN'
      response = use_client_client MailgunClient, email_object
    end

    client_response = ClientResponse.new email_object
    if response == ok_code
      client_response.set_ok
    elsif response == bad_req_code
      client_response.set_bad_req
    elsif response == internal_err_code
      client_response.set_internal_err
    end

    client_response
  end

  # Sends email using a single email client
  #
  # @param [MailgunClient|SendgridClient] email_client
  # @param [EmailObject] email_object
  # @return [Integer] response_code
  def self.use_client_client(email_client, email_object)
    begin
      response = email_client.send_email(email_object)
      puts 'Successful attempt' if response == ok_code
      puts 'Bad Request' if response == bad_req_code
      puts 'Internal Server Error' if response == internal_err_code
    rescue StandardError => e
      # Log error and fail send
      puts "Error: #{e.message}"
      response = internal_err_code
    end
    response
  end
end
