class AddExhibitPageTypeIdToExhibitSectionTypes < ActiveRecord::Migration
  class ExhibitSectionType < ActiveRecord::Base
  end
  
  def self.up
    add_column :exhibit_section_types, :exhibit_page_type_id, :integer
    begin
      @est = ExhibitSectionType.find(1)
      @est.update_attribute(:exhibit_page_type_id, 1)
      @est = ExhibitSectionType.find(2)
      @est.update_attribute(:exhibit_page_type_id, 2)
      @est = ExhibitSectionType.find(3)
      @est.update_attribute(:exhibit_page_type_id, 2)
      @est = ExhibitSectionType.find(4)
      @est.update_attribute(:exhibit_page_type_id, 2)
    rescue
    end
  end

  def self.down
    remove_column :exhibit_section_types, :exhibit_page_type_id
  end
end
