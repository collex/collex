class CreateExhibitTypesExhibitSectionTypes < ActiveRecord::Migration
  def self.up
    create_table :exhibit_section_types_exhibit_types, :id => false do |t|
      t.column :exhibit_type_id, :integer
      t.column :exhibit_section_type_id, :integer
    end
  end

  def self.down
    drop_table :exhibit_section_types_exhibit_types
  end
end
