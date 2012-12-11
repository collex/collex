class AddIndexToCachedProperties < ActiveRecord::Migration
  def change
    add_index 'cached_properties', 'cached_resource_id'
  end
end
