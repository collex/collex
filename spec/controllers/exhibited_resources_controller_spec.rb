require File.dirname(__FILE__) + '/../spec_helper'

describe ExhibitedResourcesController do
  before(:each) do
    @exhibit    = mock_model(Exhibit, :title => "Exhibit mock")
    @page_1     = mock_model(ExhibitedPage, :title => "Page 1 mock", :exhibit => @exhibit)
    @section_1  = mock_model(ExhibitedSection, :resources => [@resource_1, @resource_2], :page => @page_1)
    @resource_1 = mock_model(ExhibitedResource, :position => 1, :section => @section_1)
    @resource_2 = mock_model(ExhibitedResource, :position => 2, :section => @section_1)
    
    @exhibited_pages = mock("exhibited_pages")
    
    @owner = mock("owner")
    @owner.stub!(:username).and_return("owner")
    @viewer = mock("viewer")
    @viewer.stub!(:username).and_return("viewer")
  end 
  


end
