class CreateTagassigns < ActiveRecord::Migration
  def self.up
    create_table :tagassigns do |t|
      t.decimal :collected_item_id
      t.decimal :tag_id
      t.datetime :created_at

      t.timestamps
    end
  end

  def self.down
    drop_table :tagassigns
  end
end
