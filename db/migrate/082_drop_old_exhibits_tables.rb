class DropOldExhibitsTables < ActiveRecord::Migration
  def self.up
    rename_table :exhibit_page_types, :old_exhibit_page_types
    rename_table :exhibit_section_types, :old_exhibit_section_types
    rename_table :exhibit_section_types_exhibit_types, :old_exhibit_section_types_exhibit_types
    rename_table :exhibit_types, :old_exhibit_types
    rename_table :exhibited_items, :old_exhibited_items
    rename_table :exhibited_pages, :old_exhibited_pages
    rename_table :exhibited_properties, :old_exhibited_properties
    rename_table :exhibited_sections, :old_exhibited_sections
    rename_table :exhibits, :old_exhibits
  end

  def self.down
    rename_table :old_exhibit_page_types, :exhibit_page_types
    rename_table :old_exhibit_section_types, :exhibit_section_types
    rename_table :old_exhibit_section_types_exhibit_types, :exhibit_section_types_exhibit_types
    rename_table :old_exhibit_types, :exhibit_types
    rename_table :old_exhibited_items, :exhibited_items
    rename_table :old_exhibited_pages, :exhibited_pages
    rename_table :old_exhibited_properties, :exhibited_properties
    rename_table :old_exhibited_sections, :exhibited_sections
    rename_table :old_exhibits, :exhibits
  end
end
