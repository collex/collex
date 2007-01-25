class CreateExhibitedSections < ActiveRecord::Migration
  def self.up
    create_table :exhibited_sections do |t|
      t.column :exhibit_id, :integer, :null => false
      t.column :exhibit_section_type_id, :integer, :null => false
      t.column :position, :integer
    end
  end

  def self.down
    drop_table :exhibited_sections
  end
end
