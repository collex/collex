class CreateFacetCategories < ActiveRecord::Migration
  def self.up
    create_table :facet_categories do |t|
      t.column :parent_id, :integer
      t.column :name, :string
    end

    # Create initial set of archive facet categories    
    archive = FacetCategory.create(:name => 'archive')
    
    libraries = archive.children.create(:name => 'Libraries')
    journals = archive.children.create(:name => 'Journals')
    presses = archive.children.create(:name => 'Presses')
    projects = archive.children.create(:name => 'Projects')
    projects.children.create(:name => 'rossetti')
  end

  def self.down
    drop_table :facet_categories
  end
end
