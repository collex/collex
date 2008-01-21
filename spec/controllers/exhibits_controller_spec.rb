##########################################################################
# Copyright 2007 Applied Research in Patacriticism and the University of Virginia
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##########################################################################

require File.dirname(__FILE__) + '/../spec_helper'

describe ExhibitsController do
  fixtures :exhibits, :exhibited_items, :exhibited_sections, :users, :roles, :roles_users
  fixtures :licenses, :exhibit_section_types, :exhibit_types

  before(:each) do
    @controller = ExhibitsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @exhibit = exhibits(:dang)
    @owner = users(:exhibit_owner)
    @viewer = users(:exhibit_viewer)
    @request.session[:user] = {:username => @owner.username}
    @admin = users(:admin)
    @editor = users(:editor)    
  end
  
  it "should redirect to login for create, update, delete with bad exhibit id" do
    @request.session[:user] = nil
    assertions = proc do 
      response.should be_redirect
      response.should redirect_to(:action => "login", :controller => "login")
    end
    get(:edit, :id => -1)
    assertions.call
    
    put(:update, :id => -1)
    assertions.call
    
    delete(:destroy, :id => -1)
    assertions.call
  end

  it "should redirect to login for new, create, update, delete when not logged in" do
    @request.session[:user] = nil
    assertions = proc do 
      response.should be_redirect
      response.should redirect_to(:action => "login", :controller => "login")
    end
    get(:new)
    assertions.call

    get(:edit, :id => @exhibit.id)
    assertions.call

    post(:create)
    assertions.call

    put(:update, :id => @exhibit.id)
    assertions.call

    delete(:destroy, :id => @exhibit.id)
    assertions.call
  end
  
  it "should redirect to index with warning when trying to edit a bad exhibit id" do
    get(:edit, :id => 0)
    response.should be_redirect
    response.should redirect_to(exhibits_path)
    flash[:warning].should_not == nil
  end
  
  it "should be able to share an exhibit" do
    post(:share, :id => @exhibit.id)
    exhibit = assigns(:exhibit)
    exhibit.shared?.should be_true
    response.should be_redirect
    response.should redirect_to(exhibits_path)
  end
  
  it "should be able to unshare an exhibit" do
    @exhibit.share!
    assert(@exhibit.save)
    post(:unshare, :id => @exhibit.id)
    assert(exhibit = assigns(:exhibit), "@exhibit should have been assigned")
    exhibit.shared?.should be_false
    response.should be_redirect
    response.should redirect_to(exhibits_path)
  end
  
  it "should allow an admin to publish an exhibit" do
    Exhibit.should_receive(:find).with("#{@exhibit.id}").and_return(@exhibit)
    @exhibit.should_receive(:index!).once
    
    @request.session[:user] = {:username => @admin.username}
    @exhibit.share!
    assert(@exhibit.save)
    post(:publish, :id => @exhibit.id)
    assert(exhibit = assigns(:exhibit), "@exhibit should have been assigned")
    
    exhibit.published?.should be_true
    response.should be_redirect
    response.should redirect_to(exhibits_path)
  end
  
  it "should allow an editor to publish an exhibit" do
    Exhibit.should_receive(:find).with("#{@exhibit.id}").and_return(@exhibit)
    @exhibit.should_receive(:index!).once
    
    @request.session[:user] = {:username => @editor.username}
    @exhibit.share!
    assert(@exhibit.save)
    post(:publish, :id => @exhibit.id)
    assert(exhibit = assigns(:exhibit), "@exhibit should have been assigned")
    
    exhibit.published?.should be_true
    response.should be_redirect
    response.should redirect_to(exhibits_path)
  end
  
  it "should not allow non-owner, non-admin, non-editor to share or unshare" do
    @request.session[:user] = {:username => @viewer.username}
    post(:share, :id => @exhibit.id)
    assert(exhibit = assigns(:exhibit), "@exhibit should have been assigned")
    exhibit.shared?.should be_false
    response.should be_redirect
    response.should redirect_to(exhibits_path)

    @exhibit.share!
    @exhibit.save!
    post(:unshare, :id => @exhibit.id)
    assert(exhibit = assigns(:exhibit), "@exhibit should have been assigned")
    exhibit.shared?.should be_true
    response.should be_redirect
    response.should redirect_to(exhibits_path)
  end
  
  it "should not allow a publishing by a user who is not editor or admin" do
    @exhibit.share!
    @exhibit.save!
    post(:publish, :id => @exhibit.id)
    assert(exhibit = assigns(:exhibit), "@exhibit should have been assigned")
    exhibit.published?.should be_false
    response.should be_redirect
    response.should redirect_to(exhibits_path)
  end
end