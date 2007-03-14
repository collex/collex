class AddAnnotationAndTitleToExhibitedSection < ActiveRecord::Migration
  def self.up
    add_column :exhibited_sections, :title, :string
    add_column :exhibited_sections, :annotation, :text
  end

  def self.down
    remove_column :exhibited_sections, :title
    remove_column :exhibited_sections, :annotation
  end
end
