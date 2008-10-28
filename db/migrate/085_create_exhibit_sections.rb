class CreateExhibitSections < ActiveRecord::Migration
  def self.up
    create_table :exhibit_sections do |t|
      t.decimal :exhibit_page_id
      t.decimal :position
      t.decimal :has_border

      t.timestamps
    end
  end

  def self.down
    drop_table :exhibit_sections
  end
end
