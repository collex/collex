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

require File.dirname(__FILE__) + '/../test_helper'
require 'sidebar_controller'

# Re-raise errors caught by the controller.
class SidebarController; def rescue_action(e) raise e end; end

class SidebarControllerTest < Test::Unit::TestCase
  fixtures :interpretations
  
  def setup
    @controller = SidebarController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    @request.session[:user] = {:username => "dave"}
  end

  def test_bad_objid_detail
    get :detail, {"objid" => CollexEngine::BAD_OBJID}
    assert_response :redirect
    assert_redirected_to :controller => "sidebar", :action => "cloud" 
  end
  
  def test_update
    get :update, "tag"=>"consist of three parts",
                 "action"=>"update", 
                 "controller"=>"sidebar", 
                 "objid"=>"http://www.rossettiarchive.org/docs/1-1864.s105.raw",
                 "annotation"=>"annotate this item"
                 
     get :update, "tag"=>"consist of three parts",
                  "action"=>"update", 
                  "controller"=>"sidebar", 
                  "objid"=>"http://www.rossettiarchive.org/docs/1-1864.s105.raw",
                  "annotation"=>"annotate this item"
                 
    assert_redirected_to :action => 'detail', :objid => "http://www.rossettiarchive.org/docs/1-1864.s105.raw"
    
    user = User.find_by_username(session[:user][:username])
  end  
end
