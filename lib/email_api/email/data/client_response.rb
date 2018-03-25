require './lib/email_api/email/data/email_object'

# Defines response returned by EmailClient and is used in the API's output
class ClientResponse
  attr_reader :email
  attr_reader :status

  def initialize(email = EmailObject.new, status = 'UNDEFINED')
    @email  = email
    @status = status
  end

  def set_ok
    @status = '200: OK'
  end

  def set_bad_req
    @status = '400: BAD REQUEST'
  end

  def set_internal_err
    @status = '500: INTERNAL SERVER ERROR'
  end

  def ==(other)
    return false unless other.respond_to?(:to_hash)
    to_hash == other.to_hash
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
