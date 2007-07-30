class CreateExhibitTypeDetails < ActiveRecord::Migration
  def self.up
    create_table :section_types do |t|
      t.column :description, :string
    end
    
    create_table :exhibit_types_section_types do |t|
      t.column :exhibit_type_id, :integer
      t.column :section_type_id, :integer
    end
    
    create_table :panel_types do |t|
      t.column :description, :string
    end
    
    create_table :panel_types_section_types do |t|
      t.column :panel_type_id, :integer
      t.column :section_type_id, :integer
    end
    
  end

  def self.down
    drop_table :section_types
    drop_table :panel_types
    drop_table :exhibit_types_section_types
    drop_table :panel_types_section_types
  end
end
