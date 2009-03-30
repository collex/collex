class AddImageIdToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :image_id, :decimal
  end

  def self.down
    remove_column :users, :image_id
  end
end
