class AddShowAdminsToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :show_admins, :string
		groups = Group.all
		groups.each {|group|
			group.show_admins = 'all'
			group.save
		}
  end

  def self.down
    remove_column :groups, :show_admins
  end
end
