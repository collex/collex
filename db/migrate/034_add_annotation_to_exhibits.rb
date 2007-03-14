class AddAnnotationToExhibits < ActiveRecord::Migration
  def self.up
    add_column :exhibits, :annotation, :text
  end

  def self.down
    remove_column :exhibits, :annotation
  end
end
