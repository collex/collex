class ConfigureFacetCategories < ActiveRecord::Migration
  def self.f(value)
    FacetValue.new(:value => value)
  end
  
  def self.up
    libraries = FacetCategory.find_by_value('Libraries')
    journals = FacetCategory.find_by_value('Journals')
    presses = FacetCategory.find_by_value('Presses')
    projects = FacetCategory.find_by_value('Projects')
    
    # Libraries
    libraries << f('uva_library')
    
    # Journals
    journals << f('victbib')
    journals << f('ron')
    journals << f('JSTOR')
    
    # Presses
    uva_press = FacetCategory.new(:value => 'University of Virginia Press')
    uva_press << f('UVaPress_VLCS')
    presses << uva_press
    
    rotunda = FacetCategory.new(:value => 'Rotunda Imprint, University of Virginia')
    rotunda << f('rotunda_arnold')
    rotunda << f('rotunda_c-rossetti')
    presses << rotunda
    
    # Projects
    # Already done in original migration: projects << FacetValue.new(:value => 'rossetti')
    projects << f('poetess')
    projects << f('swinburne')
    projects << f('bierce')
    projects << f('bwrp')
    projects << f('chesnutt')
    projects << f('cbw')
    projects << f('dickinson')
    projects << f('blake')
    projects << f('cather')
    
    whitman = FacetCategory.new(:value => 'Whitman Archive')
    whitman << f('whitbib')
    whitman << f('whitman')
    projects << whitman
    
    rc = FacetCategory.new(:value => 'Romantic Circles')
    rc << f('rc')
    rc << f('rc-editions')
    rc << f('rc-resources')
    projects << rc
    
  end

  def self.down
  end
end
