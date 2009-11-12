class AddSortToSearches < ActiveRecord::Migration
  def self.up
    add_column :searches, :sort_by, :string
    add_column :searches, :sort_dir, :string
		searches = Search.all()
		searches.each { |search|
			search.sort_by = "Relevancy"
			search.sort_dir = "Ascending"
			search.save
		}
  end

  def self.down
    remove_column :searches, :sort_dir
    remove_column :searches, :sort_by
  end
end
