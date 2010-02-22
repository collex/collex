class CreatePeerReviews < ActiveRecord::Migration
  def self.up
    create_table :peer_reviews do |t|
      t.decimal :image_id

      t.timestamps
    end
  end

  def self.down
    drop_table :peer_reviews
  end
end
