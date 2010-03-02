class AddPublicationImageToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :publication_image_id, :decimal
  end

  def self.down
    remove_column :groups, :publication_image_id
  end
end
