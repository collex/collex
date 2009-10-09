class AddGenresToExhibits < ActiveRecord::Migration
  def self.up
    add_column :exhibits, :genres, :text
		Exhibit.all().each { |exhibit|
			exhibit.genres = ''
			exhibit.save
		}
  end

  def self.down
    remove_column :exhibits, :genres
  end
end
