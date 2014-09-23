class IncreaseSizeOfCachedPropertyValue < ActiveRecord::Migration
  def up
	  change_column :cached_properties, :value, :text, :limit => 4.megabytes
  end

  def down
	  change_column :cached_properties, :value, :text
  end
end
