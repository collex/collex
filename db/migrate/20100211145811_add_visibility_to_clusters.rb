class AddVisibilityToClusters < ActiveRecord::Migration
  def self.up
    add_column :clusters, :visibility, :string
		clusters = Cluster.all
		clusters.each { |cluster|
			cluster.visibility = 'everyone'
			cluster.save
		}
  end

  def self.down
    remove_column :clusters, :visibility
  end
end
