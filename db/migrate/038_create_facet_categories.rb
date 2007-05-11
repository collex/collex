class CreateFacetCategories < ActiveRecord::Migration
  def self.up
    create_table :facet_categories do |t|
      t.column :parent_id, :integer
      t.column :value, :string
      t.column :type, :string
    end

    # Create initial set of archive facet categories    
    archive = FacetTree.create(:value => 'archive')

    # Categories under the archive facet tree
    libraries = FacetCategory.new(:value => 'Libraries')
    journals = FacetCategory.new(:value => 'Journals')
    presses = FacetCategory.new(:value => 'Presses')
    projects = FacetCategory.new(:value => 'Projects')
    
    archive << libraries
    archive << journals
    archive << presses
    archive << projects
    
    # Libraries
    # Journals
    # Presses
    
    # Projects
    projects << FacetValue.new(:value => 'rossetti')
    
    archive.save
  end

  def self.down
    drop_table :facet_categories
  end
end
