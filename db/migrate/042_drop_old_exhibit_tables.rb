class DropOldExhibitTables < ActiveRecord::Migration
  def self.up
    drop_table :exhibit_types_section_types
    drop_table :panel_types
    drop_table :panel_types_section_types
    drop_table :section_types
    drop_table :sections
  end

  def self.down
    create_table "exhibit_types_section_types", :force => true do |t|
      t.column "exhibit_type_id", :integer
      t.column "section_type_id", :integer
    end

    create_table "panel_types", :force => true do |t|
      t.column "description", :string
      t.column "template",    :text
    end

    create_table "panel_types_section_types", :force => true do |t|
      t.column "panel_type_id",   :integer
      t.column "section_type_id", :integer
    end

    create_table "section_types", :force => true do |t|
      t.column "description", :string
    end
    
    create_table "sections", :force => true do |t|
      t.column "section_type_id", :integer
      t.column "exhibit_id",      :integer
    end
  end
end
