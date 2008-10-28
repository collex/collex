class CreateExhibitPages < ActiveRecord::Migration
  def self.up
    create_table :exhibit_pages do |t|
      t.decimal :exhibit_id
      t.decimal :position

      t.timestamps
    end
  end

  def self.down
    drop_table :exhibit_pages
  end
end
