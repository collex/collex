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
    assert_equal "Projects", merged[3][:value]
    assert_equal 1869, merged[3][:count]
    assert_equal 1869, merged[3][:children][0][:count]    
  end
  
  def test_totaling
    facets = {"victbib"=>12361, "whitman"=>247, "poetess"=>4216, "UVaPress_VLCS"=>50, "cather"=>720, "cbw"=>985, "whitbib"=>7636, "rc-resources"=>14, "swinburne"=>130, "dickinson"=>600, "bierce"=>196, "rossetti"=>21520, "rc"=>140, "ron"=>464, "rotunda_arnold"=>3459, "bwrp"=>3276, "chesnutt"=>413, "rc-editions"=>20, "blake"=>2942}
    uncategorized = facets.clone
    merged = @archive.merge_facets(facets, uncategorized)
    assert uncategorized.empty?
    
    libraries = merged[0]
    assert_equal "Libraries", libraries[:value]
    assert_equal 0, libraries[:count]
    
    journals = merged[1]
    assert_equal "Journals", journals[:value]
    assert_equal 12825, journals[:count]

    presses = merged[2]
    assert_equal "Presses", presses[:value]
    assert_equal 3509, presses[:count]
  end
  
end
