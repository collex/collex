require File.dirname(__FILE__) + '/../spec_helper'

describe LoginController do
  before(:each) do
    
  end
  
  it "should redirect to 'login' for authenticated action when no user in session" do
    get :controller => "collection"
    response.should redirect_to(:controller => "login", :action => "login")
  end
  
  it "valid user should login successfully" do
    post :login, {:username => 'username', :password => 'password'} 
    response.should redirect_to(:controller => "sidebar", :action => "cloud", :type => "tag")
    session[:user][:username].should == "username"
  end
  
  it "logout from exhibits should redirect to exhibits" do
    request.env["HTTP_REFERER"] = "exhibits"
    get :logout
    response.should redirect_to(:controller => "exhibits")
  end
  
  it "logout from collect redirects to browse" do
    post :login, {:username => 'username', :password => 'password'} 
    get :logout
    response.should redirect_to(:controller => "search", :action => "browse")
  end
end