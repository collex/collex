class ChangeTypeToIllustrationTypeInExhibitIllustration < ActiveRecord::Migration
  def self.up
   rename_column :exhibit_illustrations, :type, :illustration_type
  end

  def self.down
   rename_column :exhibit_illustrations, :illustration_type, :type
  end
end
