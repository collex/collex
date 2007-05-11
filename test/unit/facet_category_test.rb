require File.dirname(__FILE__) + '/../test_helper'

class FacetCategoriesTest < Test::Unit::TestCase
  fixtures :facet_categories
  
  def setup
    @archive = FacetCategory.find_by_value("archive")
  end

  def test_basic
    assert_equal 4, @archive.children.size
  end
  
  def test_to_facet_tree
    uncategorized = {}
    merged = @archive.merge_facets({'rossetti' => 1869}, uncategorized)
#    puts merged.inspect
    assert_equal "Projects", merged[3][:value]
    assert_equal 1869, merged[3][:count]
    assert_equal 1869, merged[3][:children][0][:count]    
  end
  
end
