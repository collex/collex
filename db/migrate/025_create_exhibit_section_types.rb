class CreateExhibitSectionTypes < ActiveRecord::Migration
  def self.up
    create_table :exhibit_section_types do |t|
      t.column :description, :string
      t.column :template, :string
      t.column :name, :string
    end
  end

  def self.down
    drop_table :exhibit_section_types
  end
end
