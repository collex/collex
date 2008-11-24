class AddAltTextToExhibitIllustration < ActiveRecord::Migration
  def self.up
    add_column :exhibit_illustrations, :alt_text, :string
  end

  def self.down
    remove_column :exhibit_illustrations, :alt_text
  end
end
