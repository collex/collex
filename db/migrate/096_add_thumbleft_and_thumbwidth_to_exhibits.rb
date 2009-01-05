class AddThumbleftAndThumbwidthToExhibits < ActiveRecord::Migration
  def self.up
    add_column :exhibits, :thumbleft, :decimal
    add_column :exhibits, :thumbwidth, :decimal
  end

  def self.down
    remove_column :exhibits, :thumbleft
    remove_column :exhibits, :thumbwidth
  end
end
