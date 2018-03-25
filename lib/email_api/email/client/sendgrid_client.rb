require './lib/email_api/email/data/email_object'
require 'rest-client'
require 'json'

# Client for sending email via Sendgrid v2 API
class SendgridClient
  @exp_msg           ||= 'success'
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
  # @return [int] status_code
  def self.send_email(email_object)

    # Parse Environment Values
    api_user = ENV['SENDGRID_API_USER']
    api_key  = ENV['SENDGRID_API_KEY']
    return internal_err_code if api_user.nil? || api_key.nil?

    # Build Sendgrid-specific URL and POST data
    url       = 'https://api.sendgrid.com/api/mail.send.json'
    post_data = parse_post_data(email_object, api_user, api_key)
    return bad_req_code if post_data.nil?

    # Send Email, return response
    begin
      response = RestClient.post url, post_data
    rescue StandardError => e
      # Log error and fail send -> occurs when Code 400 due to implementation
      puts "Error: #{e.message}"
      return bad_req_code
    end

    puts "Primary Client Response: #{response}"

    return bad_req_code if response.nil? || !JSON.parse(response).respond_to?(:[])

    # Handle expected output. Note that it is API specific.
    json_response = JSON.parse(response)
    if !json_response.key?('message').nil? && json_response['message'] == exp_msg
      return ok_code
    end

    internal_err_code # Unhandled response
  end

  # Parses an EmailObject into POST data for use in an API call
  #
  # @param [EmailObject] email_object
  # @return [String] post_data
  def self.parse_post_data(email_object, api_user, api_key)

    # Handle missing Environment Variables
    return nil if api_user.nil? || api_key.nil?

    # Handle missing or unsupported input parameter
    return nil if email_object.nil? || !email_object.is_a?(EmailObject)

    # Handle missing mandatory Email Attributes
    return nil if email_object.from.nil? || email_object.to.nil? ||
                  email_object.subject.nil? || email_object.content.nil?


    # Build Message Attributes
    post_data = "api_user=#{api_user}"
    post_data += "&api_key=#{api_key}"
    post_data += "&subject=#{email_object.subject}"
    post_data += "&text=#{email_object.content}"
    post_data += "&from=#{email_object.from.email}"
    post_data += "&fromname[]=#{email_object.from.name}"
    email_object.to.each do |address|
      post_data += "&to[]=#{address.email}"
      post_data += "&toname[]=#{address.name}"
    end
    unless email_object.cc.nil?
      email_object.cc.each do |address|
        post_data += "&cc[]=#{address.email}"
        post_data += "&ccname[]=#{address.name}"
      end
    end
    unless email_object.bcc.nil?
      email_object.bcc.each do |address|
        post_data += "&bcc[]=#{address.email}"
        post_data += "&bccname[]=#{address.name}"
      end
    end

    post_data
  end

  private_class_method :parse_post_data
end
