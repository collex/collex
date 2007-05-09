require File.dirname(__FILE__) + '/../test_helper'

class FacetCategoriesTest < Test::Unit::TestCase
  fixtures :facet_categories
  
  def setup
    @archive = FacetCategory.find_by_name("archive")
  end

  def test_basic
    assert_equal 4, @archive.children.size
  end
  
  def test_to_facet_tree
    forest = @archive.to_facet_tree('rossetti' => 1869)
    puts forest.inspect
    assert_equal "Projects", forest[3][:name]
    assert_equal 1869, forest[3][:count]
    assert_equal 1869, forest[3][:children][0][:count]    
  end
  
end
