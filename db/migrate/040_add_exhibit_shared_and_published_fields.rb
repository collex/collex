class AddExhibitSharedAndPublishedFields < ActiveRecord::Migration
  def self.up
    add_column :exhibits, :shared, :boolean, :default => false
    add_column :exhibits, :published, :boolean, :default => false
  end

  def self.down
    remove_column :exhibits, :shared
    remove_column :exhibits, :published
  end
end
