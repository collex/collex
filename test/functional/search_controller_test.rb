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
require 'search_controller'

# Re-raise errors caught by the controller.
class SearchController; def rescue_action(e) raise e end; end

class SearchControllerTest < Test::Unit::TestCase
  fixtures :users, :genres, :agent_types

  include TestCollexHelper
  
  def setup
    @controller = SearchController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    @request.session[:user] = {:username => "dave"}
  end
  
  def test_collect
     post :collect, { :objid => URI, :tags => "some tags", :annotation => "test annotation" }     
     assert_redirected_to :controller => 'search', :action => 'browse'      
     cached_document = CachedDocument.find_by_uri(URI)
     assert_equal URI, cached_document.uri
     assert cached_document.tags.include?("some")
     assert cached_document.genres.include?(Genre.find_by_name("Poetry"))
  end
  
end
