class CreateExhibits < ActiveRecord::Migration
  def self.up
    create_table :exhibits do |t|
      t.column :user_id, :integer
      t.column :license_id, :integer
      t.column :title, :string
      t.column :exhibit_type_id, :integer
    end
  end

  def self.down
    drop_table :exhibits
  end
end
