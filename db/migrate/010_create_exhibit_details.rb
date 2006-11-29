class CreateExhibitDetails < ActiveRecord::Migration
  def self.up
    create_table :sections do |t|
      t.column :section_type_id, :integer
      t.column :exhibit_id, :integer
    end
  end

  def self.down
    drop_table :sections
  end
end
