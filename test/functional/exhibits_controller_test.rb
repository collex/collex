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
  fixtures :exhibits

  def test_should_get_print_exhibit
    get :print_exhibit, :id => 1
    assert_response :success
  end

  def test_should_get_view
    get :view, :id => 2
    assert_response :success
  end

  def test_should_destroy_exhibit
    assert_difference('Exhibit.count', -1) do
      delete :destroy, :id => exhibits(:foo).id
    end

    assert_redirected_to exhibits_path
  end
end
