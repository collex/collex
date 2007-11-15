class AddUriToExhibits < ActiveRecord::Migration
  def self.up
    add_column :exhibits, :uri, :string
  end

  def self.down
    remove_column :exhibits, :uri
  end
end
