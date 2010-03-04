class RemoveCategoryFromExhibits < ActiveRecord::Migration
  def self.up
    remove_column :exhibits, :badge_id
    remove_column :exhibits, :category
  end

  def self.down
    add_column :exhibits, :badge_id, :decimal
    add_column :exhibits, :category, :string
  end
end
