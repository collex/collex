require File.dirname(__FILE__) + '/../spec_helper'

describe ExhibitedPage do
  fixtures :exhibits, :exhibited_pages, :exhibit_page_types, :exhibited_sections
  before(:each) do
    @ie_1 = exhibited_pages(:illustrated_essay_1)
  end

  it "'sections()' should be an alias for 'exhibited_sections'" do
    @ie_1.exhibited_sections.should == (@ie_1.sections)
    @ie_1.exhibited_sections.create({:exhibit_section_type_id => 1, :title => "IE section"})
    @ie_1.exhibited_sections.should == (@ie_1.sections)
    
    @ie_1.sections.create({:exhibit_section_type_id => 1, :title => "Another IE section"})
    @ie_1.exhibited_sections.should == (@ie_1.sections)
  end
  
  it "'sections_full?' should return true if the page has max number of sections allowed" do
    page = ExhibitedPage.new
    exhibit_page_type = mock("exhibit_page_type", :null_object => true)
    exhibit_page_type.stub!(:max_sections).and_return(3)
    page.stub!(:exhibit_page_type).and_return(exhibit_page_type)
    page.sections.stub!(:count).and_return(3)
    page.sections_full?.should == true
  end
  
  it "'sections_full?' should return false if the page has less than max number of sections allowed" do
    page = ExhibitedPage.new
    exhibit_page_type = mock("exhibit_page_type", :null_object => true)
    exhibit_page_type.stub!(:max_sections).and_return(10)
    page.stub!(:exhibit_page_type).and_return(exhibit_page_type)
    page.sections.stub!(:count).and_return(9)
    page.sections_full?.should == false
  end
end
