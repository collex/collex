class CreateExhibits < ActiveRecord::Migration
  def self.up
    create_table :exhibits do |t|
      t.string :title
      t.decimal :user_id
      t.string :thumbnail

      t.timestamps
    end
  end

  def self.down
    drop_table :exhibits
  end
end
