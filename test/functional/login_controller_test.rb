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
require File.dirname(__FILE__) + '/../test_collex_helper'
require 'login_controller'

# Re-raise errors caught by the controller.
class LoginController; def rescue_action(e) raise e end; end

class LoginControllerTest < ActionController::TestCase
  fixtures :users

  include TestCollexHelper
  
  def setup
    @controller = LoginController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    #@request.session[:user] = {:username => "dave"}
  end
    
#  def test_account_help
#    get :account_help
#    assert_response :success
#    assert_nil session[:user]
#  end
#
  def test_login_controls
    get :login_controls
    assert_response :success
    assert_nil session[:user]
  end
  
#  def test_reset_password
#    post :reset_password, { :help_username =>"illegal" }
#    assert_response :bad_request
#    assert_nil session[:user]
#
#    post :reset_password, { :help_username =>"paul" }
#    assert_response :bad_request
#    assert_equal "A new password has been e-mailed to your registered address.", @response.body
#    assert_nil session[:user]
#    email_arr = ActionMailer::Base.deliveries
#    email = email_arr[email_arr.length-1]
#    to_addr = email.header['to']
#    assert_equal 'paul@example.com', to_addr.to_s
#    assert_equal 'Collex Password Reset', email.header['subject'].to_s
#
#    # now find the new password and attempt to log in
#    body = email.body_port.to_s
#    password_prologue = "Your password is:"
#    pswd_start = body.index(password_prologue)
#    pswd_start += password_prologue.length + 3
#    new_pswd = body.slice(pswd_start, 8)
#    do_valid_login( { :expect_fail => true })
#    do_valid_login( { :password => new_pswd })
#  end
  
  def test_submit_signup
    get :submit_signup
    assert_response :success
    assert_nil session[:user]
    assert false
  end
  
#  def test_change_account
#    do_valid_login()
#    session[:current_page] = [ search_path, search_path ]
#
#    post :change_account, { :password2 => "[FILTERED]", :password =>"[FILTERED]", :email =>"paul@performantsoftware.com" }
#    assert_response :redirect
#    assert_redirected_to search_path
#    assert_equal 'paul', session[:user][:username]
#  end
  
  def test_logout
    do_valid_login()
    
    session[:current_page] = [ search_path, search_path ]
    
    get :logout
    assert_response :redirect 
    assert_redirected_to '/'
    assert_nil session[:user]
  end
  
#  def test_signup
#    get :signup
#    assert_response :success
#    assert_nil session[:user]
#  end
  
  def test_submit_signup
    post :submit_signup, { :create_password2 =>"freddy", :create_username =>"fred", :create_password => "freddy1", :create_email =>"fred@fred.com" }
    assert_response :bad_request
    assert_equal "Passwords do not match", @response.body
    assert_nil session[:user]

    post :submit_signup, { :create_password2 =>"freddy", :create_username =>"fred", :create_password => "freddy", :create_email =>"fred@fred.com" }
    assert_response :success
    assert_equal 'fred', session[:user][:username]
  end
  
  def test_verify_login
    post :verify_login, { :signin_username => "paul", :signin_password => "illegal" }
    assert_response :bad_request
    assert_nil session[:user]
    assert_equal "Invalid user/password combination", @response.body

    do_valid_login()
  end
  
  def test_recover_username
    post :recover_username, { :help_email => "illegal"}
    assert_response :bad_request
    assert_nil session[:user]

    post :recover_username, { :help_email => "dave@whatever.com"}
    assert_response :bad_request
    assert_equal "Your user name has been e-mailed to your registered address.", @response.body
    assert_nil session[:user]
  end
  
  def do_valid_login(params = nil)
    if !params
      params = {}
    end
    password = params[:password] ? params[:password] : "password"
    expect_fail = params[:expect_fail]

    post :verify_login, { :signin_username => "paul", :signin_password => password }
    if expect_fail
      assert_response :bad_request
	    assert_equal "Invalid user/password combination", @response.body
      assert_nil session[:user]
    else
      assert_response :success
      assert_equal 'paul', session[:user][:username]
    end
    end
  
#    user_search_string = "dance"
#    post :add_constraint, { :search_phrase => user_search_string }, { :name_of_search => "old_name" }
#    assert_response :redirect 
#    assert_redirected_to :action => "browse" 
#    assert_nil session[:name_of_search]
#    assert_equal 1, session[:constraints].length
#  end
end
