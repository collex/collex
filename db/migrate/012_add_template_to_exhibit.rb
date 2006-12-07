class AddTemplateToExhibit < ActiveRecord::Migration
  def self.up
    add_column :exhibit_types, :template, :text
  end

  def self.down
    remove_column :exhibit_types, :template
  end
end
