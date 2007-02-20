require File.dirname(__FILE__) + '/../../test_helper'

class SidebarHelperTest < HelperTestCase
  include SidebarHelper
  #fixtures :users, :articles

  def setup
    super
  end
  
  # title_for tests
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

  # sb_link_to_remote tests
  def test_sb_link_to_remote_generates_label_from_value
    @type = "agent"
    @value = "David Ferris"
    expected = %Q{<a onclick="new Ajax.Updater('sidebar', '/sidebar/list?type=agent&amp;value=David+Ferris', {asynchronous:true, evalScripts:true}); return false;" href="#">David Ferris</a>}
    assert_dom_equal(expected, sb_link_to_remote(@type, @value))
  end
  
  def test_sb_link_to_remote_generates_label_from_label_argument
    @type = "agent"
    @value = "David Ferris"
    @label = "LOUD LABEL"
    expected = %Q{<a onclick="new Ajax.Updater('sidebar', '/sidebar/list?type=agent&amp;value=David+Ferris', {asynchronous:true, evalScripts:true}); return false;" href="#">LOUD LABEL</a>}
    assert_dom_equal(expected, sb_link_to_remote(@type, @value, @label))
  end
  
  def test_cloud_object_renders_properly
    expected = %(<div class="cloud_object">some_user's <span class="emph2">foo objects</span></div>)
    assert_equal(expected, cloud_object("2", "some_user"))
  end
  
end
