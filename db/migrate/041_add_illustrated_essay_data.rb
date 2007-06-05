class AddIllustratedEssayData < ActiveRecord::Migration
  class ExhibitType < ActiveRecord::Base
  end
  class ExhibitSectionType < ActiveRecord::Base
  end

  def self.up
    ExhibitSectionType.delete([2,3,4])
    exhibit_section_type = ExhibitSectionType.new do |est|
      est.id = 2
      est.description = "Text Only"
      est.template = "text_only"
      est.name = "Text Only"
    end
    exhibit_section_type.save!
    exhibit_section_type = ExhibitSectionType.new do |est|
      est.id = 3
      est.description = "Illustration on Left"
      est.template = "illustration_left"
      est.name = "Illustration on Left"
    end
    exhibit_section_type.save!
    exhibit_section_type = ExhibitSectionType.new do |est|
      est.id = 4
      est.description = "Illustration on Right"
      est.template = "illustration_right"
      est.name = "Illustration on Right"
    end
    exhibit_section_type.save!
    
    ExhibitType.delete([3])
    ie_exhibit_type = ExhibitType.new do |et|
      et.id = 3
      et.description = "Illustrated Essay"
      et.template = "illustrated_essay"
    end
    ie_exhibit_type.save!
  end

  def self.down
    ExhibitSectionType.delete([2,3,4])
    ExhibitType.delete(3)
  end
end
