class CreateSavedSearches < ActiveRecord::Migration
  def self.up
    create_table :searches do |t|
      t.column :name, :string
      t.column :user_id, :integer
    end
    
    create_table :constraints do |t|
      t.column :search_id, :integer
      t.column :inverted, :boolean
      t.column :type, :string
      
      # :field and :type are used differently, based on the :type
      t.column :field, :string
      t.column :value, :string
    end
  end

  def self.down
    drop_table :searches
  end
end
