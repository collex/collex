class AddHeightToExhibitIllustrations < ActiveRecord::Migration
  def self.up
    add_column :exhibit_illustrations, :height, :decimal
  end

  def self.down
    remove_column :exhibit_illustrations, :height
  end
end
