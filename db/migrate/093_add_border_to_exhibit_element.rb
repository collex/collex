class AddBorderToExhibitElement < ActiveRecord::Migration
  def self.up
    add_column :exhibit_elements, :border_type_enum, :decimal
    add_column :exhibit_elements, :exhibit_page_id, :decimal
  end

  def self.down
    remove_column :exhibit_elements, :exhibit_page_id
    remove_column :exhibit_elements, :border_type_enum
  end
end
