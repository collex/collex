class Resource < ActiveRecord::Base
  has_many :properties
  validates_uniqueness_of :uri

  # Simplify access to properties by name.  Examples:
  #  resource.title => returns first title property found
  #  resource.titles => returns an array of properties with name "title"
  def method_missing(method_id, *arguments)
     begin
       super
     rescue NoMethodError
       name = method_id.to_s
       singular_name = name.singularize
       props = properties.select {|prop| prop.name == singular_name }
       return name == singular_name ? props[0] : props
     end
   end
end
