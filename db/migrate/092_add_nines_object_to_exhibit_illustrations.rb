class AddNinesObjectToExhibitIllustrations < ActiveRecord::Migration
  def self.up
    add_column :exhibit_illustrations, :nines_object_uri, :string
  end

  def self.down
    remove_column :exhibit_illustrations, :nines_object_uri
  end
end
