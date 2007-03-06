class RemoveResourcesAndProperties < ActiveRecord::Migration
  def self.up
    drop_table :properties
    drop_table :resources
  end

  def self.down
    create_table :resources, :options => 'TYPE=MyISAM' do |t|
      t.column :uri, :string, :limit => 512
      t.column :created_on, :datetime
      t.column :updated_on, :datetime
    end
    
    create_table :properties, :options => 'TYPE=MyISAM' do |t|
      t.column :name, :string
      t.column :value, :string, :limit => 512
      t.column :resource_id, :integer
      t.column :created_on, :datetime
      t.column :updated_on, :datetime
    end
  end
end
