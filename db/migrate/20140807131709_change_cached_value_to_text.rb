class ChangeCachedValueToText < ActiveRecord::Migration
  def up
	  remove_index :cached_properties, :value
	  change_column :cached_properties, :value, :text
  end

  def down
	  change_column :cached_properties, :value, :string
  end
end
