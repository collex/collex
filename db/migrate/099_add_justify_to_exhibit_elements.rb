class AddJustifyToExhibitElements < ActiveRecord::Migration
  def self.up
    add_column :exhibit_elements, :justify, :decimal
  end

  def self.down
    remove_column :exhibit_elements, :justify
  end
end
