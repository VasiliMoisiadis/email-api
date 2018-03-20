# Contains all parameters that defines an email address
class EmailAddress
  attr_reader :name
  attr_reader :email

  def initialize(name, email)
    @name  = name
    @email = email
  end

  def as_json(_options = {})
    { name:  @name,
      email: @email }
  end

  def to_json(*options)
    as_json(*options).to_json(*options)
  end
end
