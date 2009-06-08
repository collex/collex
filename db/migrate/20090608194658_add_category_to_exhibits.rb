class AddCategoryToExhibits < ActiveRecord::Migration
  def self.up
    add_column :exhibits, :category, :string
  end

  def self.down
    remove_column :exhibits, :category
  end
end
