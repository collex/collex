class AddAdditionalAuthorsToExhibits < ActiveRecord::Migration
  def self.up
    add_column :exhibits, :additional_authors, :string
  end

  def self.down
    remove_column :exhibits, :additional_authors
  end
end
