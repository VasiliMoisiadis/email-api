require 'backend/email/client/mailgun_client'
require 'backend/email/client/sendgrid_client'
require 'json'

# General client that sends email utilizing multiple service providers
class EmailClient

  # Sends email utilizing multiple service providers
  #
  # @param [EmailObject] email_object
  # @return [Object] response
  def self.send_email(email_object)
    failed_send = true
    # Attempt with primary client: Mailgun
    begin
      puts 'Attempting Email Sending via primary client: MAILGUN'
      response    = MailgunClient.send_email(email_object)
      failed_send = response != 200
      puts 'Successful attempt' unless failed_send
    rescue StandardError => e
      # Log error and fail send
      puts "Error: #{e.message}"
      failed_send = true
    end

    if failed_send
      # Attempt with backup secondary client: Sendgrid
      begin
        puts 'Primary client failed. Attempting secondary client: Sendgrid'
        response    = SendgridClient.send_email(email_object)
        failed_send = response != 200
        puts 'Successful attempt' unless failed_send
      rescue StandardError => e
        # Log error and fail send
        puts "Error: #{e.message}"
        failed_send = true
      end
    end

    client_response           = JSON.parse(email_object.to_json)
    client_response['status'] = (failed_send ? 'FAILURE' : 'OK')

    client_response
  end
end
