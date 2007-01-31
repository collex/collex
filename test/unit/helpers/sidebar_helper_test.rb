require File.dirname(__FILE__) + '/../../test_helper'

class SidebarHelperTest < HelperTestCase
  include SidebarHelper
  #fixtures :users, :articles

  def setup
    super
  end
  
  def test_title_for_returns_proper_title
    @object = {'title' => "The Title"}
    expected = "The Title"
    assert_equal(expected, title_for(@object))
  end
  
  def test_object_without_title_returns_untitled
    @object = {}
    expected = "<untitled>"
    assert_equal(expected, title_for(@object))
    
    @object['title'] = ""
    assert_equal(expected, title_for(@object))
  end
  
  
end
