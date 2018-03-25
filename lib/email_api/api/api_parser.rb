require './lib/email_api/email/data/email_object'
require './lib/email_api/email/data/email_address'
require 'json'

# Parser for Email API
class ApiParser
  @email_delim ||= ','

  # Accessor for the supported email delimiter
  def self.email_delim
    @email_delim
  end

  # Parses raw text into custom EmailAddress object
  #
  # @param [String] email_text Raw text denoting email
  # @return [Email Address] email_address
  def self.parse_email_text(email_text)
    return nil if email_text.nil? || !email_text.is_a?(String)

    restricted_chars = ',<>'

    # Try to parse correct format: "DISPLAY NAME <EMAIL ADDRESS>"
    name  = nil
    email = email_text[/.*<([^>]*)/, 1]
    name  = email_text.gsub(email, '') unless email.nil?
    name  = name.delete(restricted_chars).strip unless name.nil?
    email = email.delete(restricted_chars).strip unless email.nil?

    # If only one or the other found, assign value to both fields
    name  = email if (!email.nil? && !email.empty?) && (name.nil? || name.empty?)
    email = name if (!name.nil? && !name.empty?) && (email.nil? || email.empty?)

    # If neither found, take entire String as values
    name  = email = email_text.delete(restricted_chars).strip if name.nil? && email.nil?

    EmailAddress.new(name, email)
  end

  # Parse a String[] and returns an EmailAddres[]
  #
  # @param [String[]] email_text_arr Array of text, each being an email address
  # @return [EmailAddress[]] email_arr
  def self.parse_email_text_arr(email_text_arr)
    return nil if email_text_arr.nil? || !email_text_arr.is_a?(String)

    email_arr = []
    # Split on email delimiter, parse each email
    split_arr = email_text_arr.split(/(?<=[#{email_delim}])/, -1)

    # Push value on through even if empty -> handled further down
    email_arr.push(parse_email_text(email_text_arr)) if split_arr.empty?
    split_arr.each do |email_text|
      email_arr.push(parse_email_text(email_text))
    end

    email_arr = nil if !email_arr.nil? && email_arr.empty?
    email_arr
  end

  # Parses parameter inputs into an EmailObject using the supported notation
  #
  # @param [Splat] params Raw Email Attribute Values
  # @return [EmailObject] email_object Parsed email object
  def self.parse_email(*params)
    email_object = EmailObject.new

    return email_object if params.nil? || !params.is_a?(Array) || params.empty?

    to       = cc = bcc = subject = content = nil
    from     = params[0]
    to       = params[1] if params.count > 1
    cc       = params[2] if params.count > 2
    bcc      = params[3] if params.count > 3
    subj_raw = params[4] if params.count > 4
    cont_raw = params[5] if params.count > 5

    subject = nil
    if !subj_raw.nil? && (subj_raw.is_a?(String) || subj_raw.is_a?(Numeric))
      subject = subj_raw
    end

    content = nil
    if !cont_raw.nil? && (cont_raw.is_a?(String) || cont_raw.is_a?(Numeric))
      content = cont_raw
    end

    # Parse and assign Message Attributes
    email_object.from    = parse_email_text(from)
    email_object.to      = parse_email_text_arr(to)
    email_object.cc      = parse_email_text_arr(cc)
    email_object.bcc     = parse_email_text_arr(bcc)
    email_object.subject = (subject.nil? || subject.empty? ? nil : subject)
    email_object.content = (content.nil? || content.empty? ? nil : content)

    email_object
  end

  private_class_method :parse_email_text_arr, :parse_email_text
end
