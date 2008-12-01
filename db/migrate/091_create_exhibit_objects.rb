class CreateExhibitObjects < ActiveRecord::Migration
  def self.up
    create_table :exhibit_objects do |t|
      t.string :uri
      t.integer :exhibit_id

      t.timestamps
    end
  end

  def self.down
    drop_table :exhibit_objects
  end
end
