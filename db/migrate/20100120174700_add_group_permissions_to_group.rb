class AddGroupPermissionsToGroup < ActiveRecord::Migration
  def self.up
    add_column :groups, :exhibit_visibility, :string
		groups = Group.all()
		groups.each { |group|
			group.exhibit_visibility = 'open'
			group.save!
		}
  end

  def self.down
    remove_column :groups, :exhibit_visibility
  end
end
