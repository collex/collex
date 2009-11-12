class DropUnusedExhibitTables < ActiveRecord::Migration
  def self.up
		# for some reason, this was tried earlier and caused an exception. We'll try again but ignore the exception.
		begin
			drop_table :exhibit_page_types
		rescue
		end
		begin
			drop_table :exhibit_section_types
		rescue
		end
		begin
			drop_table :exhibit_section_types_exhibit_types
		rescue
		end
		begin
			drop_table :exhibit_types
		rescue
		end
		begin
			drop_table :exhibited_pages
		rescue
		end
		begin
			drop_table :exhibited_properties
		rescue
		end
		begin
			drop_table :exhibited_sections
		rescue
		end
		begin
			drop_table :exhibited_items
		rescue
		end
  end

  def self.down
    # Recreate only so that up can drop them again
    create_table :exhibited_items
    create_table :exhibited_sections
    create_table :exhibited_properties
    create_table :exhibited_pages
    create_table :exhibit_types
    create_table :exhibit_section_types_exhibit_types
    create_table :exhibit_section_types
    create_table :exhibit_page_types
  end
end
