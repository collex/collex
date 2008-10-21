class AddProfileItemsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :institution, :string
    add_column :users, :link, :string
    add_column :users, :about_me, :text
  end

  def self.down
    remove_column :users, :about_me
    remove_column :users, :link
    remove_column :users, :institution
  end
end
