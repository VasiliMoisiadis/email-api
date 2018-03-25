# Contains all parameters that defines an email address
class EmailAddress
  attr_reader :name
  attr_reader :email

  def initialize(name = nil, email = name)
    @name  = name
    @email = email
  end

  def to_hash
    hash = {}
    instance_variables.each do |var|
      name       = var.to_s.delete('@')
      value      = instance_variable_get(var)
      val_hash   = value.to_hash if value.respond_to?(:to_hash)
      hash[name] = val_hash.nil? ? value : val_hash
    end
    hash
  end
end
