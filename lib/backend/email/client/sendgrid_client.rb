require 'rest-client'
require 'json'

# Client for sending email via Sendgrid v2 API
class SendgridClient
  @exp_msg ||= 'success'

  # Sends an email over HTTPS
  #
  # @param [EmailObject] email_object
  # @return [int] status_code
  def self.send_email(email_object)
    # Build Sendgrid-specific URL and POST data
    url       = 'https://api.sendgrid.com/api/mail.send.json'
    post_data = parse_post_data(email_object)

    # Send Email, return response
    response = RestClient.post url, post_data

    # Handle expected output. Note that it is API specific.
    return 200 if JSON.parse(response)['message'] == @exp_msg

    400
  end

  # Parses an EmailObject into POST data for use in an API call
  #
  # @param [EmailObject] email_object
  # @return [String] post_data
  def self.parse_post_data(email_object)
    # Handle bad values
    if email_object.nil? || email_object.to.nil? ||
       email_object.cc.nil? || email_object.bcc.nil?
      return nil
    end

    # Parse environment values
    api_user = ENV['SENDGRID_API_USER']
    api_key  = ENV['SENDGRID_API_KEY']

    # Build Message Attributes
    post_data = "api_user=#{api_user}"
    post_data += "&api_key=#{api_key}"
    post_data += "&subject=#{email_object.subject}"
    post_data += "&text=#{email_object.content}"
    post_data += "&from=#{email_object.from.email}"
    post_data += "&fromname[]=#{email_object.from.name}"
    email_object.to.each do |email_address|
      post_data += "&to[]=#{email_address.email}"
      post_data += "&toname[]=#{email_address.name}"
    end
    unless email_object.cc.nil?
      email_object.cc.each do |email_address|
        post_data += "&cc[]=#{email_address.email}"
        post_data += "&ccname[]=#{email_address.name}"
      end
    end
    unless email_object.bcc.nil?
      email_object.bcc.each do |email_address|
        post_data += "&bcc[]=#{email_address.email}"
        post_data += "&bccname[]=#{email_address.name}"
      end
    end

    post_data
  end

  private_class_method :parse_post_data
end
