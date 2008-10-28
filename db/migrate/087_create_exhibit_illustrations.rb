class CreateExhibitIllustrations < ActiveRecord::Migration
  def self.up
    create_table :exhibit_illustrations do |t|
      t.decimal :exhibit_element_id
      t.decimal :position
      t.string :type
      t.string :image_url
      t.text :illustration_text
      t.text :caption1
      t.text :caption2
      t.decimal :image_width
      t.string :link

      t.timestamps
    end
  end

  def self.down
    drop_table :exhibit_illustrations
  end
end
