require File.dirname(__FILE__) + '/../../test_helper'

class ExhibitHelperTest < HelperTestCase
  include ExhibitHelper

  def test_simple_render
    pt = PanelType.new
    pt.template="<%=23*23%>"
    assert_equal "529", render_panel(pt)
  end
  
  def test_text_field
    pt = PanelType.new
    pt.template="<%=exhibit_field 'foo' %>"
    assert_equal "foo", render_panel(pt)

    assert_equal "<input id=\"foo\" name=\"foo\" type=\"text\" />", render_panel(pt, :edit)
  end
end
