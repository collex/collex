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

class SearchControllerTest < ActionController::TestCase
  fixtures :users, :facet_categories, :collected_items, :searches

  include TestCollexHelper
  
  def setup
    @controller = SearchController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    @request.session[:user] = {:username => "dave"}
  end
    
  def test_add_constraint
    # TODO: try this both logged in and not logged in. session[:user] = either nil or a User object
    # TODO: try this after the session has expired.
    # TODO: check the return values to make sure that the correct stuff is returned.
    # TODO: test the other variables, too.

    # other session variables: session[:selected_freeculture] = nil or true or false.
    # session[:items_per_page] = 5, 15, 30
    # session[:name_of_search] (this gets reset immediately in this call. Be sure that it is nil on exit)
    # session[:selected_resource_facets] = array of each facet name
    # session[:num_docs]

    # Called from the search on the Home page.
    user_search_string = "dance"
    post :add_constraint, { :search_phrase => user_search_string }, { :name_of_search => "old_name" }
    assert_response :redirect 
    assert_redirected_to :action => "browse" 
    assert_nil session[:name_of_search]
    assert_equal 2, session[:constraints].length

    # Called from the new search on the Search page.
#    post :add_constraint, { :search => { :keyword => user_search_string }, :search_year => "1877", :search_author => "poe", :search_editor => "poe", :search_publisher => "pocketbook" }, { :name_of_search => "old_name" }
#    assert_response :redirect
#    assert_redirected_to :action => "browse"
#    assert_nil session[:name_of_search]
#    assert_equal 5, session[:constraints].length
    
    # Called to add a constraint from the Search page
#    post :add_constraint, { :search => { :phrase => user_search_string }, :search_type => "Keyword" }, { :name_of_search => "old_name" , :constraints => session[:constraints] }
#    assert_response :redirect
#    assert_redirected_to :action => "browse"
#    assert_nil session[:name_of_search]
#    assert_equal 6, session[:constraints].length
    
#    post :add_constraint, { :search => { :phrase => user_search_string }, :search_type => "Author" }, { :name_of_search => "old_name" , :constraints => session[:constraints] }
#    assert_response :redirect
#    assert_redirected_to :action => "browse"
#    assert_nil session[:name_of_search]
#    assert_equal 7, session[:constraints].length
#
#    post :add_constraint, { :search => { :phrase => user_search_string }, :search_type => "Editor" }, { :name_of_search => "old_name" , :constraints => session[:constraints] }
#    assert_response :redirect
#    assert_redirected_to :action => "browse"
#    assert_nil session[:name_of_search]
#    assert_equal 8, session[:constraints].length
#
#    post :add_constraint, { :search => { :phrase => user_search_string }, :search_type => "Publisher" }, { :name_of_search => "old_name" , :constraints => session[:constraints] }
#    assert_response :redirect
#    assert_redirected_to :action => "browse"
#    assert_nil session[:name_of_search]
#    assert_equal 9, session[:constraints].length
#
#    post :add_constraint, { :search => { :phrase => user_search_string }, :search_type => "Year" }, { :name_of_search => "old_name" , :constraints => session[:constraints] }
#    assert_response :redirect
#    assert_redirected_to :action => "browse"
#    assert_nil session[:name_of_search]
#    assert_equal 10, session[:constraints].length
  end
  
  def test_browse
    # This called both by clicking the search tag, and if something changes in the search
    
    # This is a blank search
    get :browse, { }, { :constraints => [], :selected_freeculture => nil, :selected_resource_facets => [ 'rossetti', 'uva_library', 'victbib' ] }
    assert_response :success
    # TODO @response.body contains the HTML output
    #TODO assigns contains all the instance variables that were set by this call.
    assert_template 'results'
    assert_nil session[:name_of_search]
    assert_equal 0, session[:constraints].length
    
    # This is a non-blank search
    user_search_string = "dance"
    post :add_constraint, { :search_phrase => user_search_string, :search_type => "Keyword" }
    get :browse, { }, { :constraints => session[:constraints], :name_of_search => 'name', :selected_freeculture => nil, :selected_resource_facets => [ 'rossetti', 'uva_library', 'victbib' ] }
    assert_response :success
    # TODO @response.body contains the HTML output
    #TODO assigns contains all the instance variables that were set by this call.
    assert_template 'results'
    assert_equal 'name', session[:name_of_search]
    assert_equal 1, session[:constraints].length
  end
  
  def test_sort_by
    post :sort_by #, { :search => {'result_count' => 15} }
    assert_response :redirect
    assert_redirected_to :action => "browse"
    #assert_equal 15, session[:items_per_page]
  end

   def test_constrain_freeculture
    post :constrain_freeculture, { :freeculture => 'on' }
    assert_response :redirect 
    assert_redirected_to :action => "browse" 
    assert_equal 2, session[:constraints].length
    assert_equal 'FederationConstraint', session[:constraints][0]['type']
    assert_equal 'FreeCultureConstraint', session[:constraints][1]['type']

#    post :constrain_freeculture
#    assert_response :redirect
#    assert_redirected_to :action => "browse"
#    assert_equal 0, session[:constraints].length
  end
  
  def test_constrain_resources
    post :constrain_resource, { "resource"=> "whitman" }
    assert_response :redirect 
    assert_redirected_to :action => "browse" 
    assert_equal 2, session[:constraints].length
  end
  
  def test_invert_constraint
    user_search_string = "dance"
    post :add_constraint, { :search_phrase => user_search_string }
    post :invert_constraint, { :index => 1 }, session
    assert_response :redirect 
    assert_redirected_to :action => "browse" 
    assert_equal 2, session[:constraints].length
    assert_equal true, session[:constraints][1][:inverted]
    
    post :invert_constraint, { :index => 1 }, session
    assert_response :redirect 
    assert_redirected_to :action => "browse" 
    assert_equal 2, session[:constraints].length
    assert_equal false, session[:constraints][1][:inverted]
  end

  def test_remove_constraint
    user_search_string = "dance"
    post :add_constraint, { :search_phrase => user_search_string }
    assert_equal 2, session[:constraints].length

    post :remove_constraint, { :index => 1 }, session
    assert_response :redirect 
    assert_redirected_to :action => "browse" 
    assert_equal 1, session[:constraints].length
  end
  
  def test_new_search
    user_search_string = "dance"
    post :add_constraint, { :search_phrase => user_search_string }
    assert_equal 2, session[:constraints].length
    
    post :new_search, { }, session
    assert_response :redirect 
    assert_redirected_to :action => "browse" 
    assert_equal 1, session[:constraints].length
  end
  
  def test_add_and_remove_genre
    post :add_facet, { :field => 'genre', :value => 'Criticism' }
    assert_response :redirect 
    assert_redirected_to :action => "browse" 
    assert_equal 2, session[:constraints].length
    
    post :remove_genre, { :value =>"Criticism" }, session
    assert_response :redirect 
    assert_redirected_to :action => "browse" 
    assert_equal 1, session[:constraints].length
  end

#  def test_details
#    user_search_string = "dance"
#    post :add_constraint, { :search_phrase => user_search_string }
#
#    post :details, { :row_num => "0", :page_num => "1" }, session
#    assert_response :success
#   end

#  def test_collect_and_tags
#
#    user_search_string = "dance"
#    note = "here's an annotation"
#    tag = "jigs"
#
#    post :add_constraint, { :search_phrase => user_search_string }
#
#    post :collect, { :controller => 'result', :row_num => "0", :page_num => "1" }, session
#    assert_response :success
#
#    user = User.find_by_username(session[:user][:username])
#    collections = CollectedItem.get_all_users_collections(user)
#    assert_equal 1, collections.length
#    assert_nil collections[0][:annotation]
#
#    post :set_annotation, { :row_num => "0", :page_num => "1", :note => note }, session
#    assert_response :success
#
#    collections = CollectedItem.get_all_users_collections(user)
#    assert_equal 1, collections.length
#    assert_equal note, collections[0][:annotation]
#
#    post :add_tag, { :row_num => "0", :page_num => "1", :tag => tag }, session
#    assert_response :success
#
#    collections = CollectedItem.get_all_users_collections(user)
#    assert_equal 1, collections.length
#    tags = collections[0].tags
#    assert_equal 1, tags.length
#    assert_equal tag, tags[0].name
#
#    post :remove_tag, { :row_num => "0", :page_num => "1", :tag => tag }, session
#    assert_response :success
#
#    collections = CollectedItem.get_all_users_collections(user)
#    assert_equal 1, collections.length
#    tags = collections[0].tags
#    assert_equal 0, tags.length
#
#    post :uncollect, { :row_num => "0", :page_num => "1" }, session
#    assert_response :success
#
#    collections = CollectedItem.get_all_users_collections(user)
#    assert_equal 0, collections.length
#
#  end
  
  def test_saved_searches
    user_search_string = "dance"
    user_search_string2 = "reels"
    name = "my search"
    
    # first create a search and make sure there are no saved searches.
    post :add_constraint, { :search_phrase => user_search_string }
    assert_nil session[:name_of_search]
    if (session[:user])
      user = User.find_by_username(session[:user][:username])
      searches = user.searches.find(:all)
      assert_equal 0, searches.length
    end
    assert_equal 2, session[:constraints].length

    # save that search and see that it is saved and that the name that will appear on the web site is set.
    post :save_search, { :saved_search_name => name }, session
    assert_response :success
    if (user)
      assert_equal name, session[:name_of_search]
      searches = user.searches.find(:all)
      assert_equal 1, searches.length
      assert_equal name, searches[0].name
    end
    assert_equal 2, session[:constraints].length
    
    # do another search and see that the saved search is still there, but the name that appears on the web site is not.
    # also note that there are now two constraints
    post :add_constraint, { :search => { :phrase => user_search_string2 }, :search_type => 'Keyword' }, session
    assert_response :redirect 
    assert_redirected_to :action => "browse" 
    assert_nil session[:name_of_search]
    if (user)
      user = User.find_by_username(session[:user][:username])
      searches = user.searches.find(:all)
      assert_equal 1, searches.length
    end
    assert_equal 2, session[:constraints].length
    
    # apply the original search and see that there is now one constraint and the search name is back.
    post :saved, { :name => name, :user => 'paul' }, session
    assert_response :success
    #assert_redirected_to :action => "browse"
    if (user)
      assert_equal name, session[:name_of_search]
      searches = user.searches.find(:all)
      assert_equal 1, searches.length
      assert_equal name, searches[0].name
      #assert_equal 1, session[:constraints].length
    end
    
    # remove the saved search
    searches_id = searches ? searches[0].id : 1
    post :remove_saved_search, { :id => searches_id }, session
    assert_response :redirect 
    assert_redirected_to :action => "browse" 
    if (user)
      searches = user.searches.find(:all)
      assert_equal 0, searches.length
    end
  end
  
  def test_no_session_add_constraint
    @request.session = {}
    test_add_constraint
  end

  def test_no_session_browse
    @request.session = {}
    test_browse
  end
  
  def test_no_session_sort_by
    @request.session = {}
    test_sort_by
  end
  
  def test_no_session_constrain_freeculture
    @request.session = {}
    test_constrain_freeculture
  end
  
  def test_no_session_constrain_resources
    @request.session = {}
    test_constrain_resources
  end
  
  def test_no_session_invert_constraint
    @request.session = {}
    test_invert_constraint
  end
  
  def test_no_session_remove_constraint
    @request.session = {}
    test_remove_constraint
  end
  
  def test_no_session_new_search
    @request.session = {}
    test_new_search
  end
  
  def test_no_session_add_and_remove_genre
    @request.session = {}
    test_add_and_remove_genre
  end
  
#  def test_no_session_details
#    @request.session = {}
#    test_details
#  end
  
#  def test_no_session_collect_and_tags
#    @request.session = {}
#
#    note = "here's an annotation"
#    tag = "jigs"
#
#    # try to collect an item when no items are selected.
#    post :collect, { :row_num => "0", :page_num => "1" }, {}
#    assert_response :success
#
#    post :set_annotation, { :row_num => "0", :page_num => "1", :note => note }, {}
#    assert_response :success
#
#    post :add_tag, { :row_num => "0", :page_num => "1", :tag => tag }, {}
#    assert_response :success
#
#    post :remove_tag, { :row_num => "0", :page_num => "1", :tag => tag }, {}
#    assert_response :success
#
#    post :uncollect, { :row_num => "0", :page_num => "1" }, {}
#    assert_response :success
#  end
  
  def test_no_session_saved_searches
    @request.session = {}
    test_saved_searches
  end
end
