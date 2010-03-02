class CreatePublicationImages < ActiveRecord::Migration
  def self.up
    create_table :publication_images do |t|
      t.decimal :image_id

      t.timestamps
    end
  end

  def self.down
    drop_table :publication_images
  end
end
