class AddThumbnailToExhibits < ActiveRecord::Migration
  def self.up
    add_column :exhibits, :thumbnail, :string
  end

  def self.down
    remove_column :exhibits, :thumbnail
  end
end
