class AddDefaultExhibitsData < ActiveRecord::Migration
  class ExhibitType < ActiveRecord::Base
  end
  class ExhibitSectionType < ActiveRecord::Base
  end

  def self.up
    ExhibitSectionType.delete(1)
    exhibit_section_type = ExhibitSectionType.new do |est|
      est.id = 1
      est.description = "Citation"
      est.template = "citation"
      est.name = "Citation"
    end
    exhibit_section_type.save!
    
    ExhibitType.delete([1,2])
    text_exhibit_type = ExhibitType.new do |tet|
      tet.id = 1
      tet.description = "Text"
      tet.template = "text"
    end
    ab_exhibit_type = ExhibitType.new do |abet|
      abet.id = 2
      abet.description = "Annotated Bibliography"
      abet.template = "annotated_bibliography"
    end
    text_exhibit_type.save!
    ab_exhibit_type.save!
  end

  def self.down
    ExhibitSectionType.delete(1)
    ExhibitType.delete([1,2])
  end
end
