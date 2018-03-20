# Contains all parameters that defines an email
class EmailObject
  attr_reader :from
  attr_reader :to
  attr_reader :cc
  attr_reader :bcc
  attr_reader :subject
  attr_reader :content

  def initialize(from, to, cc, bcc, subject, content)
    @from    = from
    @to      = to
    @cc      = cc
    @bcc     = bcc
    @subject = subject
    @content = content
  end

  def as_json(_options = {})
    { from:    @from,
      to:      @to,
      cc:      @cc,
      bcc:     @bcc,
      subject: @subject,
      content: @content }
  end

  def to_json(*options)
    as_json(*options).to_json(*options)
  end
end
