class CreateCluster < ActiveRecord::Migration
  def self.up
    create_table :clusters do |t|
      t.string :name
      t.text :description
      t.decimal :group_id
      t.decimal :image_id

      t.timestamps
    end
  end

  def self.down
    drop_table :clusters
  end
end
