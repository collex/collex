class AddLastChangeToExhibits < ActiveRecord::Migration
  def self.up
    add_column :exhibits, :last_change, :datetime

		exhibits = Exhibit.all()
		exhibits.each{ |exhibit|
			exhibit.last_change = Time.now()
			exhibit.save
		}
  end

  def self.down
    remove_column :exhibits, :last_change
  end
end
