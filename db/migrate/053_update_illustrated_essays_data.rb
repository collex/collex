class UpdateIllustratedEssaysData < ActiveRecord::Migration
  class ExhibitSectionType < ActiveRecord::Base
  end

  def self.up
    ExhibitSectionType.delete([2,3,4]) rescue nil
    ExhibitSectionType.find_by_template("illustrations") do |ext|
      ext.name = "Generic Illustrated Essay Template"
      ext.template = "ie_generic"
      ext.description = "Generic Illustrated Essay Template"
      ext.save!
    end
  end

  def self.down
    ExhibitSectionType.find_by_template("ie_generic") do |ext|
      ext.name = "Illustrations Only"
      ext.template = "illustrations"
      ext.description = "Illustrations Only Section Template"
      ext.save!
    end
    ExhibitSectionType.delete([2,3,4]) rescue nil
    ExhibitSectionType.new do |est|
      est.id = 2
      est.description = "Text Only"
      est.template = "text_only"
      est.name = "Text Only"
      est.exhibit_page_type_id = 2
      est.save!
    end

    ExhibitSectionType.new do |est|
      est.id = 3
      est.description = "Illustration on Left"
      est.template = "illustration_left"
      est.name = "Illustration on Left"
      est.exhibit_page_type_id = 2
      est.save!
    end

    ExhibitSectionType.new do |est|
      est.id = 4
      est.description = "Illustration on Right"
      est.template = "illustration_right"
      est.name = "Illustration on Right"
      est.exhibit_page_type_id = 2
      est.save!
    end

  end
end
