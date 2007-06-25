class AddIllustrationsTypeToSectionTypes < ActiveRecord::Migration
  class ExhibitSectionType < ActiveRecord::Base
  end
  
  def self.up
    ExhibitSectionType.destroy(5) rescue nil
    @est = ExhibitSectionType.new do |est|
      est.id = 5
      est.name = "Illustrations Only"
      est.description = "Illustrations Only Section"
      est.template = "illustrations"
      est.exhibit_page_type_id = 2
    end
    @est.save!
    
  end

  def self.down
    ExhibitSectionType.destroy(5) rescue nil
  end
end
