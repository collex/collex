class CreateExhibitedResources < ActiveRecord::Migration
  def self.up
    create_table :exhibited_resources do |t|
      t.column :resource_id, :integer, :null => false
      t.column :exhibited_section_id, :integer, :null => false
      t.column :citation, :string
      t.column :annotation, :text
      t.column :position, :integer
    end
  end

  def self.down
    drop_table :exhibited_resources
  end
end
