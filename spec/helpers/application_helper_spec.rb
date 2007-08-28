require File.dirname(__FILE__) + '/../spec_helper'


describe ApplicationHelper do
  URI = 'http://test/uri'
  before(:each) do
    @item = {'uri' => URI}
    @er = mock_model(ExhibitedResource)
    @generic_site = mock_model(Site, :thumbnail => '')
    @specific_site = mock_model(Site, :thumbnail => 'http://some.site.url.com/image.gif', :description => 'Site Description')
  end


  it "'thumbnail_image' shoud get generic image when no others" do  
    Site.should_receive(:find_by_code).with('generic').and_return(@generic_site)
    item = @item.merge({'archive' => 'generic', 'title' => 'The Generic'})
    expected = %(<img src="#{DEFAULT_THUMBNAIL_IMAGE_PATH}" alt="The Generic" align="left" id="thumbnail_#{URI}"/>)
    result = thumbnail_image_tag(item)
    assert_dom_equal(expected, result)
  end
  
  it "thumbnail_image_tag should get site image when no specific thumbnail" do
    Site.should_receive(:find_by_code).with('site').and_return(@specific_site)
    item = @item.merge({'archive' => 'site', 'title' => 'Specific Site Title'})
    expected = %(<img src="http://some.site.url.com/image.gif" alt="Specific Site Title" align="left" id="thumbnail_#{URI}"/>)
    result = thumbnail_image_tag(item)
    assert_dom_equal(expected, result)
  end
  
  it "'thumbnail_image_tag' should get thumbnail of specific item when present" do
    Site.should_receive(:find_by_code).with('site').and_return(@specific_site)
    item = @item.merge({'archive' => 'site', 'title' => 'Specific Site Title', 'thumbnail' => 'http://some.specific.url.com/image.gif'})
    expected = %(<img src="http://some.specific.url.com/image.gif" alt="Specific Site Title" align="left" id="thumbnail_#{URI}"/>)
    result = thumbnail_image_tag(item)
    assert_dom_equal(expected, result)
  end

  it "'thumbnail_image_tag' without extension" do
    Site.should_receive(:find_by_code).with('site').and_return(@specific_site)
    item = @item.merge({'archive' => 'site', 'title' => 'Specific Site Title', 'thumbnail' => 'http://www.purl.org/swinburnearchive/img/tsa9thmb00/'})
    expected = %(<img src="http://www.purl.org/swinburnearchive/img/tsa9thmb00/" alt="Specific Site Title" align="left" id="thumbnail_#{URI}"/>)
    result = thumbnail_image_tag(item)
    assert_dom_equal(expected, result)
  end
  
  it "'pluralize' should work like rails version" do
    pluralize(1, "person").should == "1 person"
    pluralize(2, "person").should == "2 people"
    pluralize(2, "person", "persons").should == "2 persons"
  end
  
  it "'pluralize' should render no number" do
    pluralize(1, "person", nil, false).should == "person"
    pluralize(2, "person", nil, false).should == "people"
    pluralize(2, "person", "persons", false).should == "persons"
  end

end