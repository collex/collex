class RemoveCarouselTitleFromFacetCategories < ActiveRecord::Migration
  def self.up
    remove_column :facet_categories, :carousel_title
  end

  def self.down
    add_column :facet_categories, :carousel_title, :string
  end
end
