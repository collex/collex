require File.dirname(__FILE__) + '/../spec_helper'

describe ExhibitedPagesController do
  before(:each) do
    @exhibit = mock_model(Exhibit)
    @exhibit.stub!(:id).and_return(2)
    @exhibit.stub!(:title).and_return("Exhibit mock")
    @page_1 = mock_model(ExhibitedPage)
    @page_1.stub!(:id).and_return(1)
    @page_1.stub!(:exhibit_page_type_id).and_return(1)
    
    @exhibited_pages = mock("exhibited_pages")
    
    @owner = mock("owner")
    @owner.stub!(:username).and_return("owner")
    @viewer = mock("viewer")
    @viewer.stub!(:username).and_return("viewer")
  end
  #Delete these examples and add some real ones
  it "should use ExhibitedPagesController" do
    controller.should be_an_instance_of(ExhibitedPagesController)
  end
  
  it "GET 'index' should return a list of an exhibit's pages" do
    Exhibit.stub!(:find).and_return(@exhibit)
    @exhibit.should_receive(:exhibited_pages).and_return([])
    @exhibit.stub!(:updatable_by?).and_return(true)
    
    get :index, :exhibit_id => @exhibit.id
    response.should be_success 
    assigns[:exhibit].should equal(@exhibit)
    assigns[:exhibited_pages].should_not be_nil
  end
  
  it "GET 'show' should return just that page of the exhibit" do
    Exhibit.should_receive(:find).with("#{@exhibit.id}").and_return(@exhibit)
    @exhibited_pages.should_receive(:find).with("1").and_return(@page_1)
    @exhibit.should_receive(:viewable_by?).and_return(true)
    @exhibit.should_receive(:exhibited_pages).and_return(@exhibited_pages)
    
    get :show, :exhibit_id => @exhibit.id, :id => 1
    response.should be_success 
    assigns[:exhibit].should equal(@exhibit)
    assigns[:exhibited_page].should equal(@page_1)
  end

  it "GET 'edit' without logged in user should redirect to login" do
    get :edit
    response.should be_redirect
    flash[:notice].should eql("please log in")
  end
  
  it "GET 'edit' with logged in user but not authorization should redirect to exhibits_path" do
    request.session[:user] = {:username => @viewer.username}
    Exhibit.should_receive(:find).with("2").and_return(@exhibit)
    @exhibit.should_receive(:updatable_by?).and_return(false)
    get :edit, :id => @page_1.id, :exhibit_id => @exhibit.id
    response.should be_redirect
    response.should redirect_to(exhibits_path)
    flash[:warning].should eql("You do not have permission to edit that Exhibit!")
  end  
  
  it "GET 'edit' with authorized owner should render" do
    request.session[:user] = {:username => @owner.username}
    Exhibit.stub!(:find).and_return(@exhibit)
    @exhibit.stub!(:exhibited_pages).and_return(@exhibited_pages)
    @exhibit.stub!(:updatable_by?).and_return(true)
    @exhibited_pages.should_receive(:find).with("1").and_return(@page_1)
    
    get :edit, :id => @page_1.id, :exhibit_id => @exhibit.id
    response.should be_success
    assigns[:exhibit].should equal(@exhibit)
    assigns[:exhibited_page].should equal(@page_1)
  end
  
  it "GET 'creative_commons' should create new entry if it's not already in licenses table" do
    request.session[:user] = {:username => @owner.username}
    license_url = "http://fake.url.org/ccl"
    license_button = "http://fake.url.org/button"
    license_name = "cc name"
    get :creative_commons, :license_name => license_name, :license_url => license_url, :license_button => license_button
    response.should be_success
    assigns[:license].name.should == license_name
    assigns[:license].button_url.should == license_button
    assigns[:license].url.should == license_url
    
    assigns[:license].should eql(License.find_by_url(license_url))
  end
  
  it "GET 'creative_commons' should find existing entry by url" do
    request.session[:user] = {:username => @owner.username}
    license_url = "http://fake.url.org/ccl"
    license_button = "http://fake.url.org/button"
    license_name = "cc name"
    license = License.new(:name => license_name, :url => license_url, :button_url => license_button)
    License.stub!(:find_by_url).and_return(license)
    get :creative_commons, :license_name => license_name, :license_url => license_url, :license_button => license_button
    response.should be_success
    assigns[:license].id.should == license.id
  end

end
