class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.string :name
      t.decimal :owner
      t.text :description
      t.string :group_type
      t.decimal :image_id
      t.string :forum_permissions

      t.timestamps
    end
  end

  def self.down
    drop_table :groups
  end
end
