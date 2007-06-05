class AddIllustratedEssayTypeAssociationsData < ActiveRecord::Migration

  class ExhibitType < ActiveRecord::Base
    has_and_belongs_to_many :exhibit_section_types
  end
  class ExhibitSectionType < ActiveRecord::Base
    has_and_belongs_to_many :exhibit_types
  end

  def self.up
    @et = ExhibitType.find(3)
    @ests = ExhibitSectionType.find([2,3,4])
    @et.exhibit_section_types << @ests
    @et.save!
  end
  def self.down
    @et = ExhibitType.find(3)
    @ests = @et.exhibit_section_types.find([2,3,4])
    @ests.each do |est|
      @et.exhibit_section_types.delete(est)      
    end
    @et.save!
  end
end
