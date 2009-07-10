class CreateExhibitFootnotes < ActiveRecord::Migration
  def self.up
    create_table :exhibit_footnotes do |t|
      t.text :footnote

      t.timestamps
    end

    add_column :exhibit_elements, :header_footnote_id, :decimal
    add_column :exhibit_illustrations, :caption1_footnote_id, :decimal
    add_column :exhibit_illustrations, :caption2_footnote_id, :decimal
  end

  def self.down
    drop_table :exhibit_footnotes
		remove_column :exhibit_elements, :header_footnote_id
		remove_column :exhibit_illustrations, :caption1_footnote_id
		remove_column :exhibit_illustrations, :caption2_footnote_id
  end
end
