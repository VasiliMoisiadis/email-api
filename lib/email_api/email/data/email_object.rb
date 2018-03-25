# Contains all parameters that defines an email
class EmailObject
  attr_accessor :from
  attr_accessor :to
  attr_accessor :cc
  attr_accessor :bcc
  attr_accessor :subject
  attr_accessor :content

  def initialize(*params)
    @from    = params[0]
    @to      = params[1]
    @cc      = params[2]
    @bcc     = params[3]
    @subject = params[4]
    @content = params[5]
  end

  def ==(other)
    return false unless other.respond_to?(:to_hash)
    to_hash == other.to_hash
  end

  def to_hash
    hash = {}
    instance_variables.each do |var|
      name     = var.to_s.delete('@')
      value    = instance_variable_get(var)
      val_hash = value.to_hash if value.respond_to?(:to_hash)

      # Array doesn't implicitly convert to hash automatically
      if val_hash.nil? && value.is_a?(Array)
        val_hash = []
        value.each do |val|
          val_hash.push val.to_hash if val.respond_to?(:to_hash)
        end
      end

      hash[name] = val_hash.nil? ? value : val_hash
    end
    hash
  end
end
