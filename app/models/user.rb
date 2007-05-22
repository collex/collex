class User < ActiveRecord::Base
  has_many :interpretations, :dependent => :destroy
  has_many :exhibits
  has_and_belongs_to_many :roles
  has_many :searches
  
  def role_names
    self.roles.collect { |role| role.name }
  end
  
  # Added boolean convenience attribute for role names
  def method_missing(method, *args, &block)
    if method.to_s =~ /\?$/ and role_names.include?(method.to_s.chop)
      true
    else
      super
    end
  end
end
