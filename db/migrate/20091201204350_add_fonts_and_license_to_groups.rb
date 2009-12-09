class AddFontsAndLicenseToGroups < ActiveRecord::Migration
  def self.up
		add_column :groups, :license_type, :decimal
    add_column :groups, :header_font_name, :string
    add_column :groups, :header_font_size, :string
    add_column :groups, :illustration_font_name, :string
    add_column :groups, :illustration_font_size, :string
    add_column :groups, :text_font_name, :string
    add_column :groups, :text_font_size, :string
    add_column :groups, :caption1_font_name, :string
    add_column :groups, :caption1_font_size, :string
    add_column :groups, :caption2_font_name, :string
    add_column :groups, :caption2_font_size, :string
    add_column :groups, :endnotes_font_name, :string
    add_column :groups, :endnotes_font_size, :string
    add_column :groups, :footnote_font_name, :string
    add_column :groups, :footnote_font_size, :string
  end

  def self.down
    remove_column :groups, :footnote_font_size
    remove_column :groups, :footnote_font_name
    remove_column :groups, :endnotes_font_size
    remove_column :groups, :endnotes_font_name
    remove_column :groups, :caption2_font_size
    remove_column :groups, :caption2_font_name
    remove_column :groups, :caption1_font_size
    remove_column :groups, :caption1_font_name
    remove_column :groups, :text_font_size
    remove_column :groups, :text_font_name
    remove_column :groups, :illustration_font_size
    remove_column :groups, :illustration_font_name
    remove_column :groups, :header_font_size
    remove_column :groups, :header_font_name
    remove_column :groups, :license_type
  end
end
