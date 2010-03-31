class AddImageFullIdToPeerReviews < ActiveRecord::Migration
  def self.up
    add_column :peer_reviews, :image_full_id, :decimal
    remove_column :peer_reviews, :image_id
  end

  def self.down
    remove_column :peer_reviews, :image_full_id
    add_column :peer_reviews, :image_id, :decimal
  end
end
