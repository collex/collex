class ChangeExhibitedPageAnnotationToTextType < ActiveRecord::Migration
  def self.up
    change_column :exhibited_pages, :annotation, :text
  end

  def self.down
    change_column :exhibited_pages, :annotation, :string
  end
end
