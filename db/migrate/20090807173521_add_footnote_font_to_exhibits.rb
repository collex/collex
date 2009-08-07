class AddFootnoteFontToExhibits < ActiveRecord::Migration
  def self.up
    add_column :exhibits, :footnote_font_name, :string
    add_column :exhibits, :footnote_font_size, :string

		exhibits = Exhibit.all()
		for exhibit in exhibits
			exhibit.reset_fonts_to_default()
		end
  end

  def self.down
    remove_column :exhibits, :footnote_font_size
    remove_column :exhibits, :footnote_font_name
  end
end
