require './lib/email_api/email/data/email_address'
require './lib/email_api/email/data/email_object'
require 'rest-client'
require 'json'

# Client for sending email via Mailgun v3 API
class MailgunClient
  @exp_msg           ||= 'Queued. Thank you.'
  @ok_code           ||= 200
  @bad_req_code      ||= 400
  @internal_err_code ||= 500

  # Accessor for the expected success message
  def self.exp_msg
    @exp_msg
  end

  # Accessor for the OK Code
  def self.ok_code
    @ok_code
  end

  # Accessor for the Bad Request Code
  def self.bad_req_code
    @bad_req_code
  end

  # Accessor for the Internal Server Error Code
  def self.internal_err_code
    @internal_err_code
  end

  # Sends an email over HTTPS
  #
  # @param [EmailObject] email_object
  # @return [Response] rest_client_response
  def self.send_email(email_object)

    # Build Mailgun-specific URL and POST data
    api_key = ENV['MAILGUN_PRIVATE_KEY']
    domain  = ENV['MAILGUN_DOMAIN']
    return internal_err_code if api_key.nil? || domain.nil?

    post_data = parse_post_data(email_object, domain)
    return bad_req_code if post_data.nil?

    url = "https://api:#{api_key}@api.mailgun.net/v3/#{domain}/messages"

    # Send Email, return response
    begin
      response = RestClient.post url, post_data
    rescue StandardError => e
      # Log error and fail send -> occurs when Code 400 due to implementation
      puts "Error: #{e.message}"
      return bad_req_code
    end

    puts "Secondary Client Response: #{response}"

    # Handle expected output. Note that it is API specific.
    return ok_code if JSON.parse(response)['message'] == exp_msg

    bad_req_code
  end

  # Parses email address into proper, supported text format
  #
  # @param [EmailAddress] email_address
  # @return [String] email_address_text
  def self.parse_addr_text(email_address)
    return nil if email_address.nil? || !email_address.is_a?(EmailAddress)
    "#{email_address.name} <#{email_address.email}>"
  end

  # Parses array of email addresses into proper, supported text format
  #
  # @param [EmailAddress[]] email_address_arr
  # @return [String] email_field
  def self.parse_addr_arr(email_address_arr)
    return '' if email_address_arr.nil? || !email_address_arr.is_a?(Array)

    # Convert array of multiple email addresses to proper text format
    email_field = ''
    email_address_arr.each do |email_address|
      addr_text = parse_addr_text(email_address)
      unless addr_text.nil?
        email_field += ', ' unless email_field.empty?
        email_field += addr_text
      end
    end

    email_field
  end

  # Parses an EmailObject into POST data for use in an API call
  #
  # @param [EmailObject] email_object
  # @return [String] post_data
  def self.parse_post_data(email_object, domain)
    # Handle missing or unsupported input parameter
    return nil if email_object.nil? || domain.nil? || !email_object.is_a?(EmailObject)

    # Handle missing mandatory Email Attributes
    return nil if email_object.from.nil? || email_object.to.nil? ||
                  email_object.subject.nil? || email_object.content.nil?

    # Parse environment value and build Mailgun-specific FROM email
    from_email = EmailAddress.new(email_object.from.name, "mailgun@#{domain}")

    # Build Message Attributes
    post_data           = {}
    post_data[:from]    = parse_addr_text(from_email)
    post_data[:to]      = parse_addr_arr(email_object.to)
    post_data[:cc]      = parse_addr_arr(email_object.cc) unless email_object.cc.nil?
    post_data[:bcc]     = parse_addr_arr(email_object.bcc) unless email_object.bcc.nil?
    post_data[:subject] = email_object.subject.to_s
    post_data[:text]    = email_object.content.to_s

    post_data
  end

  private_class_method :parse_addr_text, :parse_addr_arr, :parse_post_data
end
