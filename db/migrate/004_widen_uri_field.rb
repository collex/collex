class WidenUriField < ActiveRecord::Migration
  def self.up
    change_column(:interpretations, :object_uri, :string, :limit => 512)
  end

  def self.down
    # no need to do anything - leave the column wider
  end
end
