class DropFacetCategories < ActiveRecord::Migration
  def up
	  begin
	  drop_table :facet_categories
	  rescue
	 end
  end

  def down
	  create_table :facet_categories, :force => true do |t|
		  t.column :parent_id, :integer
		  t.column :value, :string
		  t.column :type, :string
		  t.column :carousel_include, :decimal
		  t.column :carousel_description, :text
		  t.column :carousel_url, :string
		  t.column :image_id, :decimal
	  end
  end
end
