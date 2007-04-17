class RemoveUnusedTables < ActiveRecord::Migration
  def self.up
    drop_table :approvals
    drop_table :errors
    drop_table :exchanges
    drop_table :tasks
    drop_table :titles
  end

  def self.down
    # Recreate only so that up can drop them again
    create_table :approvals
    create_table :errors
    create_table :exchanges
    create_table :tasks
    create_table :titles
  end
end
