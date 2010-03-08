class AddImageFullToPublicationImages < ActiveRecord::Migration
  def self.up
    add_column :publication_images, :image_full_id, :decimal
    remove_column :publication_images, :image_id
  end

  def self.down
    remove_column :publication_images, :image_full_id
    add_column :publication_images, :image_id, :decimal
  end
end
