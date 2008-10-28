class CreateExhibitElements < ActiveRecord::Migration
  def self.up
    create_table :exhibit_elements do |t|
      t.decimal :exhibit_section_id
      t.decimal :position
      t.string :exhibit_element_layout_type
      t.text :element_test

      t.timestamps
    end
  end

  def self.down
    drop_table :exhibit_elements
  end
end
