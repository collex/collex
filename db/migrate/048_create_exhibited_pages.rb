class CreateExhibitedPages < ActiveRecord::Migration
  def self.up
    create_table :exhibited_pages do |t|
      t.column :exhibit_id, :integer
      t.column :exhibit_page_type_id, :integer
      t.column :position, :integer
      t.column :title, :string
      t.column :annotation, :string
    end
  end

  def self.down
    drop_table :exhibited_pages
  end
end
