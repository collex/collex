class AddThumbtopToExhibits < ActiveRecord::Migration
  def self.up
    add_column :exhibits, :thumbtop, :decimal
  end

  def self.down
    remove_column :exhibits, :thumbtop
  end
end
