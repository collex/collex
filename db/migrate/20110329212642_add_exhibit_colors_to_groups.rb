class AddExhibitColorsToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :exhibit_header_color, :string
    add_column :groups, :exhibit_text_color, :string
	add_column :groups, :exhibit_caption1_color, :string
	add_column :groups, :exhibit_caption1_background, :string
	add_column :groups, :exhibit_caption2_color, :string
	add_column :groups, :exhibit_caption2_background, :string
  end

  def self.down
	  remove_column :groups, :exhibit_caption2_background
	  remove_column :groups, :exhibit_caption2_color
	  remove_column :groups, :exhibit_caption1_background
	  remove_column :groups, :exhibit_caption1_color
    remove_column :groups, :exhibit_text_color
    remove_column :groups, :exhibit_header_color
  end
end
