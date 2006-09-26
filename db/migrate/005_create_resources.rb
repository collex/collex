class CreateResources < ActiveRecord::Migration
  def self.up
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

    # migrate interpretation.object_uri to pointers to resource.id and change interpretations to has_one :resource (?)
  end

  def self.down
    drop_table :resources
    drop_table :properties
  end
end
