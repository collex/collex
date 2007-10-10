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
require 'admin_message_controller'

# Re-raise errors caught by the controller.
class AdminMessageController
  # Re-raise errors caught by the controller.
  def rescue_action(e) raise e end;

  attr_accessor :consider_local

  def local_request?
    @consider_local
  end
end
  

class AdminMessageControllerTest < Test::Unit::TestCase
  
  fixtures :sites

  def setup
    @controller = AdminMessageController.new
    @controller.consider_local = true
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_add_site
    now = Time.now
    post :add_site, :code => 'test', :description => "Description: #{now}"
    assert_response :success
    
    site = Site.find_by_code('test')
    assert_equal "Description: #{now}", site.description
  end

  def test_site_exists
    post :add_site, :code => 'rossetti', :description => "New description"
    assert_response :success

    site = Site.find_by_code('rossetti')
    assert_equal "New description", site.description
  end

  def test_local_only_access
    @controller.consider_local = false
    get :add_site
    assert_response 401
  end
end
