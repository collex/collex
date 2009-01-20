class AddElementText2ToExhibitElement < ActiveRecord::Migration
  def self.up
    add_column :exhibit_elements, :element_text2, :text
  end

  def self.down
    remove_column :exhibit_elements, :element_text2
  end
end
