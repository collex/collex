class RemoveLeftoverJunk < ActiveRecord::Migration
  def self.up
    drop_table :contributors
    remove_column(:users, :isEditor)
  end

  def self.down
    # Recreate only so that up can drop them again on migrating upwards
    create_table :contributors do |t|
    end
    add_column(:users, :isEditor, :boolean)
  end
end
