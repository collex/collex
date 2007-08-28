class CreateExhibitedProperties < ActiveRecord::Migration
  def self.up
    create_table :exhibited_properties do |t|
      t.column :exhibited_resource_id, :integer
      t.column :name, :string
      t.column :value, :string
    end
  end

  def self.down
    drop_table :exhibited_properties
  end
end
