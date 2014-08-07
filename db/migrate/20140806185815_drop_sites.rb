class DropSites < ActiveRecord::Migration
  def up
	  drop_table :sites
  end

  def down
	  create_table :sites, :force => false do |t|
		  t.column :code, :string
		  t.column :url, :string
		  t.column :description, :string
		  t.column :thumbnail, :string
	  end
  end
end
