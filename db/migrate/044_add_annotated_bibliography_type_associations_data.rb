class AddAnnotatedBibliographyTypeAssociationsData < ActiveRecord::Migration

  class ExhibitType < ActiveRecord::Base
    has_and_belongs_to_many :exhibit_section_types
  end
  class ExhibitSectionType < ActiveRecord::Base
    has_and_belongs_to_many :exhibit_types
  end

  def self.up
    @et = ExhibitType.find(2)
    @est = ExhibitSectionType.find(1)
    @et.exhibit_section_types << @est
    @et.save!
  end
  def self.down
    @et = ExhibitType.find(2)
    @est = @et.exhibit_section_types.find(1)
    @et.exhibit_section_types.delete(@est)
    @et.save!
  end
end
