class AssociateExhibitedSectionsWithExhibitedPages < ActiveRecord::Migration
  def self.up
    rename_column :exhibited_sections, :exhibit_id, :exhibited_page_id
  end

  def self.down
    rename_column :exhibited_sections, :exhibited_page_id, :exhibit_id
  end
end
