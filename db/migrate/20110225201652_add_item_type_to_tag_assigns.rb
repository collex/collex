class AddItemTypeToTagAssigns < ActiveRecord::Migration
  def self.up
    
    add_column :tagassigns, :item_type, "ENUM('collected', 'uncollected')"
    add_column :tagassigns, :cached_resource_id, :integer
    add_column :tagassigns, :assigned_by_user_id, :integer
    
    # determine who added all of the collected item tags and fill in the
    # asigned_by_user_id field appropriately. Set all to type 'collected'
    puts "Migrating existing data..."
    assigns = Tagassign.all
    assigns.each do | assign |
       item = CollectedItem.find( assign.collected_item_id)
       assign.assigned_by_user_id = item.user_id
       assign.item_type = :collected
       assign.save!
    end
    
    puts "DONE"
  end

  def self.down
    remove_column :tagassigns, :item_type
    remove_column :tagassigns, :cached_resource_id
    remove_column :tagassigns, :assigned_by_user_id
  end
end
