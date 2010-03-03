class CreateSearchUserContents < ActiveRecord::Migration
  def self.up
    create_table :search_user_contents do |t|
      t.datetime :last_indexed
	  t.decimal :seconds_spent_indexing
	  t.decimal :objects_indexed

      t.timestamps
    end
  end

  def self.down
    drop_table :search_user_contents
  end
end
