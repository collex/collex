require File.dirname(__FILE__) + '/../../test_helper'

class ApplicationHelperTest < HelperTestCase

  include ApplicationHelper

  #fixtures :users, :articles

  # mock of ApplicationHelper#site()
  def site(code)
    case code
    when 'generic'
      Site.new do |s|
        s.thumbnail = ''
      end
    when 'site'
      Site.new do |s|
        s.description = 'Site Description'
        s.thumbnail = 'http://some.site.url.com/image.gif'
      end
    end
  end
  
  def test_thumbnail_image_tag_should_get_generic_image_when_no_others
    item = {'archive' => 'generic', 'title' => 'The Generic'}
    expected = %(<img src="#{DEFAULT_THUMBNAIL_IMAGE_PATH}" alt="The Generic" align="left"/>)
    result = thumbnail_image_tag(item)
    puts result
    assert_dom_equal(expected, result)    
  end
  
  def test_thumbnail_image_tag_should_get_site_image_when_no_specific_thumbnail
    item = {'archive' => 'site', 'title' => 'Specific Site Title'}
    expected = %(<img src="http://some.site.url.com/image.gif" alt="Specific Site Title" align="left"/>)
    result = thumbnail_image_tag(item)
    puts result
    assert_dom_equal(expected, result)
  end
  
  def test_thumbnail_image_tag_should_get_thumbnail_of_specific_item_when_present
    item = {'archive' => 'site', 'title' => 'Specific Site Title', 'thumbnail' => 'http://some.specific.url.com/image.gif'}
    expected = %(<img src="http://some.specific.url.com/image.gif" alt="Specific Site Title" align="left"/>)
    result = thumbnail_image_tag(item)
    puts result
    assert_dom_equal(expected, result)
  end

  def test_thumbnail_image_tag_without_extension
    item = {'archive' => 'site', 'title' => 'Specific Site Title', 'thumbnail' => 'http://www.purl.org/swinburnearchive/img/tsa9thmb00/'}
    expected = %(<img src="http://www.purl.org/swinburnearchive/img/tsa9thmb00/" alt="Specific Site Title" align="left"/>)
    result = thumbnail_image_tag(item)
    puts result
    assert_dom_equal(expected, result)
  end
  
end
