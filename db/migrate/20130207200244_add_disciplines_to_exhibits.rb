class AddDisciplinesToExhibits < ActiveRecord::Migration
	def self.up
		add_column :exhibits, :disciplines, :text
		Exhibit.all().each { |exhibit|
			exhibit.disciplines = ''
			exhibit.save
		}
	end

	def self.down
		remove_column :exhibits, :disciplines
	end
end
