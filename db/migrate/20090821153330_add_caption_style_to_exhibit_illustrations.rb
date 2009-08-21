class AddCaptionStyleToExhibitIllustrations < ActiveRecord::Migration
  def self.up
    add_column :exhibit_illustrations, :caption1_bold, :decimal
    add_column :exhibit_illustrations, :caption1_italic, :decimal
    add_column :exhibit_illustrations, :caption1_underline, :decimal
    add_column :exhibit_illustrations, :caption2_bold, :decimal
    add_column :exhibit_illustrations, :caption2_italic, :decimal
    add_column :exhibit_illustrations, :caption2_underline, :decimal

		exhibit_illustrations = ExhibitIllustration.all()
		exhibit_illustrations.each { |illustration|
			illustration.caption1_bold = 0
			illustration.caption1_italic = 0
			illustration.caption1_underline = 0
			illustration.caption2_bold = 0
			illustration.caption2_italic = 0
			illustration.caption2_underline = 0
			illustration.save
		}
  end

  def self.down
    remove_column :exhibit_illustrations, :caption2_underline
    remove_column :exhibit_illustrations, :caption2_italic
    remove_column :exhibit_illustrations, :caption2_bold
    remove_column :exhibit_illustrations, :caption1_underline
    remove_column :exhibit_illustrations, :caption1_italic
    remove_column :exhibit_illustrations, :caption1_bold
  end
end
