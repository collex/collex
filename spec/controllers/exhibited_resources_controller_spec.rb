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
  

  it "'move_higher' without logged in user should redirect to login" do
    post :move_higher
    response.should be_redirect
    flash[:notice].should eql("please log in")
    response.should redirect_to(:controller => :login, :action => :login)
  end
  
  it "'move_higher' with logged in user but not authorization should redirect to exhibits_path" do
    request.session[:user] = {:username => @viewer.username}
    Exhibit.stub!(:find).and_return(@exhibit)
    @exhibit.should_receive(:updatable_by?).and_return(false)
    post :move_higher, :exhibit_id => @exhibit.id, :page_id => @page_1.id, :section_id => @section_1.id, :id => @resource_1.id
    response.should be_redirect
    response.should redirect_to(exhibits_path)
    flash[:warning].should eql("You do not have permission to edit that Exhibit!")
  end  
  
  it "authorized 'move_higher', 'move_lower', 'move_to_top', 'move_to_bottom' should move resource and redirect to edit_pages_path" do
    request.session[:user] = {:username => @owner.username}
    Exhibit.stub!(:find).and_return(@exhibit)
    @exhibit.stub!(:updatable_by?).and_return(true)
    ExhibitedResource.stub!(:find).and_return(@resource_1)

    [:move_higher, :move_lower, :move_to_top, :move_to_bottom].each do |command|
      @resource_1.should_receive(command).and_return(true)
      post command, :exhibit_id => @exhibit.id, :page_id => @page_1.id, :section_id => @section_1.id, :id => @resource_1.id
      response.should be_redirect
      response.should redirect_to(edit_page_path(:exhibit_id => @exhibit.id, :id => @page_1.id, :anchor => "exhibited_resource_#{@resource_1.id}"))
    end
  end

end
