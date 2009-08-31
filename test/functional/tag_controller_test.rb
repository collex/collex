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
require 'tag_controller'

class TagControllerTest < ActionController::TestCase
  fixtures :users, :collected_items, :cached_resources, :cached_properties, :tags, :tagassigns, :roles, :roles_users

  def test_set_zoom
    post :set_zoom, { :level => '1' }
    assert_response :success
    assert_equal 1, session[:tag_zoom]
    
    post :set_zoom, { :level => '6' }
    assert_response :success
    assert_equal 6, session[:tag_zoom]
  end

  def test_list
    # call this with all the different variations. The data can either be from the session data, or can be passed in as params.
    get :list, { }, { :user => nil, :tag_current => nil }
    assert_response :success
    
    get :list, { :tag => 'pauls_tag' }, { :user => nil, :tag_current => nil }
    assert_response :success
    assert_equal 'pauls_tag', session[:tag_current]

    get :list, { :tag => 'not_a_tag' }, { :user => nil, :tag_current => nil }
    assert_response :success
    assert_equal 'not_a_tag', session[:tag_current]

    get :list, { }, { :user => nil, :tag_current => 'pauls_tag' }
    assert_response :success
    assert_equal 'pauls_tag', session[:tag_current]

    get :list, { :tag => 'pauls_tag' }, { :user => {:username => "paul", :role_names => []}, :tag_current => nil}
    assert_response :success
    assert_equal 'pauls_tag', session[:tag_current]

    get :list, { :tag => 'not_a_tag' }, { :user => {:username => "paul", :role_names => []}, :tag_current => nil }
    assert_response :success
    assert_equal 'not_a_tag', session[:tag_current]

    get :list, { }, { :user => {:username => "paul", :role_names => []}, :tag_current => 'pauls_tag' }
    assert_response :success
    assert_equal 'pauls_tag', session[:tag_current]
  end

  def test_results
    get :results, { :view => 'all_collected' }, {}
    assert_response :success
    get :results, { :view => 'untagged' }, {}
    assert_response :success
    get :results, { :view => 'tag', :tag => 'good' }, {}
    assert_response :success
    get :results, { :view => 'tag', :tag => 'bad' }, {}
    assert_response :success

    get :results, { :view => 'all_collected' }, { :user => {:username => "paul", :role_names => []} }
    assert_response :success
    get :results, { :view => 'untagged' }, { :user => {:username => "paul", :role_names => []} }
    assert_response :success
    get :results, { :view => 'tag', :tag => 'good' }, { :user => {:username => "paul", :role_names => []} }
    assert_response :success
    get :results, { :view => 'tag', :tag => 'bad' }, { :user => {:username => "paul", :role_names => []} }
    assert_response :success


    get :results, { }, { :tag_view => 'all_collected' }
    assert_response :success
    get :results, { }, { :tag_view => 'untagged' }
    assert_response :success
    get :results, { }, { :tag_view => 'tag', :tag_current => 'good' }
    assert_response :success
    get :results, { }, { :tag_view => 'tag', :tag_current => 'bad' }
    assert_response :success

    get :results, { }, { :user => {:username => "paul", :role_names => []}, :tag_view => 'all_collected' }
    assert_response :success
    get :results, { }, { :user => {:username => "paul", :role_names => []}, :tag_view => 'untagged' }
    assert_response :success
    get :results, { }, { :user => {:username => "paul", :role_names => []}, :tag_view => 'tag', :tag_current => 'good' }
    assert_response :success
    get :results, { }, { :user => {:username => "paul", :role_names => []}, :tag_view => 'tag', :tag_current => 'bad' }
    assert_response :success
  end

  def test_sort_by
    post :sort_by #, { :search => { :result_count => "15" } }
    assert_response :redirect 
    assert_redirected_to :action => "results" 
    #assert_equal 15, session[:items_per_page]
  end

  def test_update_tag_cloud
    post :update_tag_cloud
    assert_response :success
  end

  def test_rss
    post :rss
    assert_response :success
  end

  def test_object
    post :object
    assert_response :success
  end
end
