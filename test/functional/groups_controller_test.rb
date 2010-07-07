# ------------------------------------------------------------------------
#     Copyright 2009 Applied Research in Patacriticism and the University of Virginia
#
#     Licensed under the Apache License, Version 2.0 (the "License");
#     you may not use this file except in compliance with the License.
#     You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#     Unless required by applicable law or agreed to in writing, software
#     distributed under the License is distributed on an "AS IS" BASIS,
#     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#     See the License for the specific language governing permissions and
#     limitations under the License.
# ----------------------------------------------------------------------------

require 'test_helper'

class GroupsControllerTest < ActionController::TestCase
  fixtures :groups
  fixtures :users

	def login
		session[:user] = { :username => 'dave' }
	end
	
   test "should create group" do
    assert_difference('Group.count') do
      post :create, :group => { }
    end

    assert_response :success
  end

  test "should show group" do
    get :show, :id => groups(:one).to_param
    assert_response :success
  end

  test "should update group" do
	  login()
    put :update, :id => groups(:one).to_param, :group => { }
     assert_response :success
  end

  test "should destroy group" do
    assert_difference('Group.count', -1) do
      delete :destroy, :id => groups(:one).to_param
    end

    assert_redirected_to "/communities"
  end

	test "stale_request" do
		get :stale_request
		assert_response :success
	end

	test "accept_request" do
		get :accept_request
		assert_response :redirect
		assert_redirected_to :action => "stale_request"
	end

	test "decline_request" do
		get :decline_request
		assert_response :redirect
		assert_redirected_to :action => "stale_request"
	end

	test "decline_invitation" do
		get :decline_invitation
		assert_response :redirect
		assert_redirected_to :action => "stale_request"
	end

	test "accept_invitation" do
		get :accept_invitation
		assert_response :redirect
		assert_redirected_to :action => "stale_request"
	end

	test "acknowledge_notification" do
		get :acknowledge_notification
		assert_response :redirect
		assert_redirected_to '/static/nines/422.html'
	end

	test "create_login" do
		get :create_login
		assert_response :redirect
		assert_redirected_to '/static/nines/422.html'
	end

	test "create_login_create" do
		post :create_login_create
		assert_response :redirect
		assert_redirected_to '/groups/create_login?message=Illegal+call.'
	end
end
