class AddColorsToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :header_color, :string
    add_column :groups, :header_background_color, :string
    add_column :groups, :link_color, :string
	groups = Group.all()
	groups.each {|group|
		group.header_color = ''
		group.header_background_color = ''
		group.link_color = ''
		group.save
	}
  end

  def self.down
    remove_column :groups, :link_color
    remove_column :groups, :header_background_color
    remove_column :groups, :header_color
  end
end
