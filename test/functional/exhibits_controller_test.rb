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

class ExhibitsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:exhibits)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_exhibit
    assert_difference('Exhibit.count') do
      post :create, :exhibit => { }
    end

    assert_redirected_to exhibit_path(assigns(:exhibit))
  end

  def test_should_show_exhibit
    get :show, :id => exhibits(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => exhibits(:one).id
    assert_response :success
  end

  def test_should_update_exhibit
    put :update, :id => exhibits(:one).id, :exhibit => { }
    assert_redirected_to exhibit_path(assigns(:exhibit))
  end

  def test_should_destroy_exhibit
    assert_difference('Exhibit.count', -1) do
      delete :destroy, :id => exhibits(:one).id
    end

    assert_redirected_to exhibits_path
  end
end
