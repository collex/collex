class RenameExhibitedResourcesToExhibitedItems < ActiveRecord::Migration
  class ExhibitedItem < ActiveRecord::Base; end

  def self.up
    rename_table :exhibited_resources, :exhibited_items
    add_column :exhibited_items, :type, :string

    ExhibitedItem.update_all("type = 'ExhibitedResource' ")
  end

  def self.down
    remove_column :exhibited_items, :type
    rename_table :exhibited_items, :exhibited_resources
  end
end
