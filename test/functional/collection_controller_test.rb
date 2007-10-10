##########################################################################
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
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
require 'collection_controller'

# Re-raise errors caught by the controller.
class CollectionController; def rescue_action(e) raise e end; end

class CollectionControllerTest < Test::Unit::TestCase
  fixtures :users
  
  def setup
    @controller = CollectionController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    @request.session[:user] = {:username => "dave"}
  end

  def test_collect
     # tests that collect page is gotten to successfully, meaning the session has a user
     get :collect, :url => 'http://www.foo.com'
     assert_response :success
  end
  
  def test_add
     uri = "http://www.rossettiarchive.org/docs/test.test"
     
     post :add, {"tags-#{uri}" => "some tags", "notes-#{uri}" => "test annotation"}
     
     assert_response :success
  end
  
end
