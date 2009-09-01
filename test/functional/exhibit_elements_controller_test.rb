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

require File.dirname(__FILE__) + '/../test_helper'

class ExhibitElementsControllerTest < ActionController::TestCase
  fixtures :exhibit_elements, :users
  def test_should_redirect_if_not_authorized
    get :index
    assert_response :redirect
    assert_redirected_to '/'
  end

  def test_should_get_index
		session[:user] = { :username => 'admin', :role_names => 'admin' }
    get :index
    assert_response :success
    assert_not_nil assigns(:exhibit_elements)
  end

  def test_should_get_edit
		session[:user] = { :username => 'admin', :role_names => 'admin' }
    get :edit, :id => exhibit_elements(:one).id
    assert_response :success
  end

  def test_should_update_exhibit_element
		session[:user] = { :username => 'admin', :role_names => 'admin' }
    put :update, :id => exhibit_elements(:one).id, :exhibit_element => { }
    assert_redirected_to exhibit_element_path(assigns(:exhibit_element))
  end

  def test_should_destroy_exhibit_element
		session[:user] = { :username => 'admin', :role_names => 'admin' }
    assert_difference('ExhibitElement.count', -1) do
      delete :destroy, :id => exhibit_elements(:one).id
    end

    assert_redirected_to exhibit_elements_path
  end
end
