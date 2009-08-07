class AddFontsToExhibits < ActiveRecord::Migration
  def self.up
    add_column :exhibits, :header_font_name, :string
    add_column :exhibits, :header_font_size, :string
    add_column :exhibits, :illustration_font_name, :string
    add_column :exhibits, :illustration_font_size, :string
    add_column :exhibits, :text_font_name, :string
    add_column :exhibits, :text_font_size, :string
    add_column :exhibits, :caption1_font_name, :string
    add_column :exhibits, :caption1_font_size, :string
    add_column :exhibits, :caption2_font_name, :string
    add_column :exhibits, :caption2_font_size, :string
    add_column :exhibits, :endnotes_font_name, :string
    add_column :exhibits, :endnotes_font_size, :string
  end

  def self.down
    remove_column :exhibits, :endnotes_font_size
    remove_column :exhibits, :endnotes_font_name
    remove_column :exhibits, :caption2_font_size
    remove_column :exhibits, :caption2_font_name
    remove_column :exhibits, :caption1_font_size
    remove_column :exhibits, :caption1_font_name
    remove_column :exhibits, :text_font_size
    remove_column :exhibits, :text_font_name
    remove_column :exhibits, :illustration_font_size
    remove_column :exhibits, :illustration_font_name
    remove_column :exhibits, :header_font_size
    remove_column :exhibits, :header_font_name
  end
end
