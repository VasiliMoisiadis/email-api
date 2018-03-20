require 'backend/email/data/email_object'
require 'backend/email/data/email_address'
require 'json'

# Parser for Backend API
class ApiParser
  @email_delim ||= '|'

  # Parses raw text into custom EmailAddress object
  #
  # @param [String] email_text Raw text denoting email
  # @return [Email Address] email_address
  def self.parse_email_text(email_text)
    # Try to parse correct format: "DISPLAY NAME <EMAIL ADDRESS>"
    name  = email_text[/.+?(?=<)/, 0]
    email = email_text[/.*<([^>]*)/, 1]

    name  = name.strip unless name.nil?
    email = email.strip unless name.nil?

    # If nothing found, get entire text as email address
    name  = email = email_text.strip if name.nil? || email.nil?

    EmailAddress.new(name, email)
  end

  # Parse a String[] and returns an EmailAddres[]
  #
  # @param [String[]] email_text_arr Array of text, each being an email address
  # @return [EmailAddress[]] email_arr
  def self.parse_email_text_arr(email_text_arr)
    return nil if email_text_arr.nil?

    email_arr = []
    # Split on email delimiter, parse each email
    split_arr = email_text_arr.split(@email_delim)
    split_arr.each { |email_text|
      email_arr.push(parse_email_text(email_text))
    }
    email_arr = nil if email_arr.empty?
    email_arr
  end

  # Parses a hash into an EmailObject using the supported notation
  #
  # @param [Hash] email_hash Hash representation of EmailObjects
  # @return [EmailObject] email_object
  def self.parse_email(email_hash)
    # Parse Message Attributes
    from_email = parse_email_text(email_hash['from'])
    to_email   = parse_email_text_arr(email_hash['to'])
    cc_email   = parse_email_text_arr(email_hash['cc'])
    bcc_email  = parse_email_text_arr(email_hash['bcc'])
    subject    = email_hash['subject'] ? email_hash['subject'] : 'subj'
    content    = email_hash['content'] ? email_hash['content'] : 'cont'

    # Output received values
    puts '== Parsed Parameters =='
    puts from_email.to_json unless from_email.nil?
    puts to_email.to_json unless to_email.nil?
    puts cc_email.to_json unless cc_email.nil?
    puts bcc_email.to_json unless bcc_email.nil?
    puts '======================='

    EmailObject.new(from_email, to_email, cc_email, bcc_email, subject, content)
  end

  private_class_method :parse_email_text_arr, :parse_email_text
end
