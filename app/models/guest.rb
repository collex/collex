class Guest
  def id
    -1
  end

  # the guest user will have these roles:
  ROLES = ['guest']
  
  # will return false for any method <role_name>_role? that is not in ROLES and true for those in ROLES
  def method_missing(method, *args, &block)
    if method.to_s =~ /_role\?$/ 
      ROLES.include?(method.to_s[0..-7])
    else
      super
    end
  end

  def role_names
    ROLES
  end
  
  def username
    "guest"
  end
  
end