class AddCarouselToFacetCategories < ActiveRecord::Migration
  def self.up
    add_column :facet_categories, :carousel_include, :decimal
    add_column :facet_categories, :carousel_title, :string
    add_column :facet_categories, :carousel_description, :text
    add_column :facet_categories, :carousel_url, :string
    add_column :facet_categories, :image_id, :decimal
  end

  def self.down
    remove_column :facet_categories, :image_id
    remove_column :facet_categories, :carousel_url
    remove_column :facet_categories, :carousel_description
    remove_column :facet_categories, :carousel_title
    remove_column :facet_categories, :carousel_include
  end
end
