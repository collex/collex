class ChangeExhibitedResourceResourceIdToUri < ActiveRecord::Migration
  def self.up
    add_column :exhibited_resources, :uri, :string
    remove_column :exhibited_resources, :resource_id
  end

  def self.down
    remove_column :exhibited_resources, :uri
    add_column :exhibited_resources, :resource_id, :integer
  end
end
