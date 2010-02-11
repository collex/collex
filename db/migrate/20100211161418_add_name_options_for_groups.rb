class AddNameOptionsForGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :exhibits_label, :string
    add_column :groups, :clusters_label, :string
		groups = Group.all
		groups.each { |group|
			group.exhibits_label = 'Exhibit'
			group.clusters_label = 'Cluster'
			group.save
		}
  end

  def self.down
    remove_column :groups, :clusters_label
    remove_column :groups, :exhibits_label
  end
end
