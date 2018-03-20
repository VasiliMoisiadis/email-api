require 'backend/email/data/email_address'
require 'rest-client'
require 'json'

# Client for sending email via Mailgun v3 API
class MailgunClient
  @exp_msg ||= 'Queued. Thank you.'

  # Sends an email over HTTPS
  #
  # @param [EmailObject] email_object
  # @return [Response] rest_client_response
  def self.send_email(email_object)

    # Build Mailgun-specific URL and POST data
    api_key   = ENV['MAILGUN_PRIVATE_KEY']
    domain    = ENV['MAILGUN_DOMAIN']
    url       = "https://api:#{api_key}@api.mailgun.net/v3/#{domain}/messages"
    post_data = parse_post_data(email_object, domain)

    # Send Email, return response
    response = RestClient.post url, post_data

    # Handle expected output. Note that it is API specific.
    return 200 if JSON.parse(response)['message'] == @exp_msg

    400
  end

  # Parses email address into proper, supported text format
  #
  # @param [EmailAddress] email_address
  # @return [String] email_address_text
  def self.parse_addr_text(email_address)
    "#{email_address.name} <#{email_address.email}>"
  end

  # Parses array of email addresses into proper, supported text format
  #
  # @param [EmailAddress[]] email_address_arr
  # @return [String] email_field
  def self.parse_addr_arr(email_address_arr)
    return '' if email_address_arr.nil?

    # Convert array of multiple email addresses to proper text format
    email_field = ''
    (0..email_address_arr.length - 1).each do |field_idx|
      email_address = email_address_arr[field_idx]
      email_field   += ', ' if field_idx > 0
      email_field   += parse_addr_text(email_address)
    end

    email_field
  end

  # Parses an EmailObject into POST data for use in an API call
  #
  # @param [EmailObject] email_object
  # @return [String] post_data
  def self.parse_post_data(email_object, domain)
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
