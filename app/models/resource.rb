class Resource < ActiveRecord::Base
  has_many :properties
  validates_uniqueness_of :uri

  # Simplify access to properties by name.  Examples:
  #  resource.title => returns first title property found
  #  resource.titles => returns an array of properties with name "title"
  def method_missing(method_id, *arguments)
     begin
     def validate
        unless title
         errors.add(:title, "dc:title element is missing")
        end
        unless date
         errors.add(:date, "dc:date element is missing.")
        end
        unless object_id
         errors.add(:id, "Object id element is missing.")
        end  
        unless roles
         errors.add(:role, "At least one role required.")
        end
        unless genres
         errors.add(:nogenre, "At least one genre required")
        end
        genreType = nil;
        genres.each do |thisGenre|
         if (thisGenre == "Primary") || (thisGenre=="Secondary")
            if (genreType)
              errors.add(:genreconflict, "Conflicting genre types:  Both Primary and Secondary present")
            else
              genreType = thisGenre
            end
         end
            if not (acceptableGenres.include?(thisGenre))
              errors.add(:badgenre, thisGenre+" is not an acceptable value for nines:genre")
            end
         end   
        if genreType == nil 
          errors.add(:primarysecondary, "Genre not specified as Primary or Secondary")
        end   
        
        
       super
     rescue NoMethodError
       name = method_id.to_s
       singular_name = name.singularize
       props = properties.select {|prop| prop.name == singular_name }
       return name == singular_name ? props[0] : props
     end
   end
end
