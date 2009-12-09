class AddLicenseTypeToExhibits < ActiveRecord::Migration
  def self.up
    add_column :exhibits, :license_type, :decimal
		exhibits = Exhibit.all()
		exhibits.each {|exhibit|
			if exhibit.is_published == 0 || exhibit.is_published == nil
				exhibit.license_type = 4
				exhibit.is_published = 0
			else
				exhibit.license_type = exhibit.is_published
				exhibit.is_published = 1
			end
			exhibit.category = "classroom" if exhibit.category == "student"
			exhibit.category = "community" if exhibit.category == "sandbox" || exhibit.category == nil
			exhibit.save
		}
  end

  def self.down
		exhibits = Exhibit.all()
		exhibits.each {|exhibit|
			if exhibit.is_published != 0
				exhibit.is_published = exhibit.license_type
				exhibit.save
			end
		}
    remove_column :exhibits, :license_type
  end
end
