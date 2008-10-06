class DeleteTagIdFromCollectedItemTable < ActiveRecord::Migration
  def self.up
    remove_column :collected_items, :tag_id 
  end

  def self.down
    add_column :collected_items, :tag_id, :integer 
  end
end
