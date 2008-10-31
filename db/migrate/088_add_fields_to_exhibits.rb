class AddFieldsToExhibits < ActiveRecord::Migration
  def self.up
    rename_column :exhibit_elements, :element_test, :element_text
    add_column :exhibits, :visible_url, :string
    add_column :exhibits, :is_published, :decimal
  end

  def self.down
    remove_column :exhibits, :is_published
    remove_column :exhibits, :visible_url
    rename_column :exhibit_elements, :element_text, :element_test
  end
end
