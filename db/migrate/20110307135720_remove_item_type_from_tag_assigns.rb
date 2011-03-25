class RemoveItemTypeFromTagAssigns < ActiveRecord::Migration
  def self.up
    
    # fix user name column
    rename_column :tagassigns, :assigned_by_user_id, :user_id
    
    puts "Migrating existing data..."
    assigns = Tagassign.all
    assigns.each do | assign |
       if assign.item_type == :collected.to_s
         item = CollectedItem.find( assign.collected_item_id)
         assign.cached_resource_id = item.cached_resource_id
         assign.save!
       end
    end
    
    puts "Update schema..."
    remove_column :tagassigns, :item_type
    remove_column :tagassigns, :collected_item_id
    
    puts "DONE"
  end

  def self.down
    puts 'Restoring old columns...'
    add_column :tagassigns, :item_type, "ENUM('collected', 'uncollected')"
    add_column :tagassigns, :collected_item_id, :integer
    rename_column :tagassigns, :user_id, :assigned_by_user_id
    
    puts 'Fix data...'
    assigns = Tagassign.all
    assigns.each do | assign |
      item = CollectedItem.find_by_user_id_and_cached_resource_id(assign.assigned_by_user_id, assign.cached_resource_id)
      if item.nil?
        assign.item_type = :uncollected
      else 
        assign.item_type = :collected
        assign.collected_item_id = item.id
      end 
      assign.save!
    end
    
    puts "DONE"
  end
end
