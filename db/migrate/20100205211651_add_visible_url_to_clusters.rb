class AddVisibleUrlToClusters < ActiveRecord::Migration
  def self.up
    add_column :clusters, :visible_url, :string
  end

  def self.down
    remove_column :clusters, :visible_url
  end
end
