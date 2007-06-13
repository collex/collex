class AddExhibitPageData < ActiveRecord::Migration
  class ExhibitPageType < ActiveRecord::Base
  end
  
  def self.up
    ExhibitPageType.destroy([1,2]) rescue nil
    @ept = ExhibitPageType.new do |ept|
      ept.id = 1
      ept.name = "Annotated Bibliography Page Type"
      ept.description = "Annotated Bibliography pages have one section per page."
      ept.template = "base_page"
      ept.min_sections = 1
      ept.max_sections = 1
      ept.exhibit_type_id = 2
    end
    @ept.save!
    
    @ept = ExhibitPageType.new do |ept|
      ept.id = 2
      ept.name = "Illustrated Essay Page Type"
      ept.description = "Illustrated Essay pages can have 100 sections per page."
      ept.template = "base_page"
      ept.min_sections = 1
      ept.max_sections = 100
      ept.exhibit_type_id = 3
    end
    @ept.save!
  end

  def self.down
    ExhibitPageType.destroy([1,2])
  end
end
