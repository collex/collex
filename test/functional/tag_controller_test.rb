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
    get :list, { }, { :user => nil, :tag_current => nil, :tag_which => nil }
    assert_response :success
    
    get :list, { :tag => 'pauls_tag', :which => 'my' }, { :user => nil, :tag_current => nil, :tag_which => nil }
    assert_response :success
    assert_equal 'pauls_tag', session[:tag_current]
    assert_equal 'my', session[:tag_which]

    get :list, { :tag => 'pauls_tag', :which => 'all' }, { :user => nil, :tag_current => nil, :tag_which => nil }
    assert_response :success
    assert_equal 'pauls_tag', session[:tag_current]
    assert_equal 'all', session[:tag_which]

    get :list, { :tag => 'not_a_tag', :which => 'all' }, { :user => nil, :tag_current => nil, :tag_which => nil }
    assert_response :success
    assert_equal 'not_a_tag', session[:tag_current]
    assert_equal 'all', session[:tag_which]

    get :list, { :which => 'my' }, { :user => nil, :tag_current => 'pauls_tag', :tag_which => nil }
    assert_response :success
    assert_equal 'pauls_tag', session[:tag_current]
    assert_equal 'my', session[:tag_which]

    get :list, { }, { :user => nil, :tag_current => 'pauls_tag', :tag_which => 'all' }
    assert_response :success
    assert_equal 'pauls_tag', session[:tag_current]
    assert_equal 'all', session[:tag_which]

    get :list, { :tag => 'not_a_tag'}, { :user => nil, :tag_current => nil, :tag_which => 'my' }
    assert_response :success
    assert_equal 'not_a_tag', session[:tag_current]
    assert_equal 'my', session[:tag_which]


    get :list, { :tag => 'pauls_tag', :which => 'my' }, { :user => {:username => "paul", :role_names => []}, :tag_current => nil, :tag_which => nil }
    assert_response :success
    assert_equal 'pauls_tag', session[:tag_current]
    assert_equal 'my', session[:tag_which]

    get :list, { :tag => 'pauls_tag', :which => 'all' }, { :user => {:username => "paul", :role_names => []}, :tag_current => nil, :tag_which => nil }
    assert_response :success
    assert_equal 'pauls_tag', session[:tag_current]
    assert_equal 'all', session[:tag_which]

    get :list, { :tag => 'not_a_tag', :which => 'all' }, { :user => {:username => "paul", :role_names => []}, :tag_current => nil, :tag_which => nil }
    assert_response :success
    assert_equal 'not_a_tag', session[:tag_current]
    assert_equal 'all', session[:tag_which]

    get :list, { :which => 'my' }, { :user => {:username => "paul", :role_names => []}, :tag_current => 'pauls_tag', :tag_which => nil }
    assert_response :success
    assert_equal 'pauls_tag', session[:tag_current]
    assert_equal 'my', session[:tag_which]

    get :list, { }, { :user => {:username => "paul", :role_names => []}, :tag_current => 'pauls_tag', :tag_which => 'all' }
    assert_response :success
    assert_equal 'pauls_tag', session[:tag_current]
    assert_equal 'all', session[:tag_which]

    get :list, { :tag => 'not_a_tag'}, { :user => {:username => "paul", :role_names => []}, :tag_current => nil, :tag_which => 'my' }
    assert_response :success
    assert_equal 'not_a_tag', session[:tag_current]
    assert_equal 'my', session[:tag_which]
  end

  def test_results
    get :results, { :view => 'all_collected' }, {}
    assert_response :success
    get :results, { :view => 'untagged' }, {}
    assert_response :success
    get :results, { :view => 'tag', :which => 'my', :tag => 'good' }, {}
    assert_response :success
    get :results, { :view => 'tag', :which => 'my', :tag => 'bad' }, {}
    assert_response :success
    get :results, { :view => 'tag', :which => 'all', :tag => 'good' }, {}
    assert_response :success

    get :results, { :view => 'all_collected' }, { :user => {:username => "paul", :role_names => []} }
    assert_response :success
    get :results, { :view => 'untagged' }, { :user => {:username => "paul", :role_names => []} }
    assert_response :success
    get :results, { :view => 'tag', :which => 'my', :tag => 'good' }, { :user => {:username => "paul", :role_names => []} }
    assert_response :success
    get :results, { :view => 'tag', :which => 'my', :tag => 'bad' }, { :user => {:username => "paul", :role_names => []} }
    assert_response :success
    get :results, { :view => 'tag', :which => 'all', :tag => 'good' }, { :user => {:username => "paul", :role_names => []} }
    assert_response :success

    get :results, { }, { :tag_view => 'all_collected' }
    assert_response :success
    get :results, { }, { :tag_view => 'untagged' }
    assert_response :success
    get :results, { }, { :tag_view => 'tag', :tag_which => 'my', :tag_current => 'good' }
    assert_response :success
    get :results, { }, { :tag_view => 'tag', :tag_which => 'my', :tag_current => 'bad' }
    assert_response :success
    get :results, { }, { :tag_view => 'tag', :tag_which => 'all', :tag_current => 'good' }
    assert_response :success

    get :results, { }, { :user => {:username => "paul", :role_names => []}, :tag_view => 'all_collected' }
    assert_response :success
    get :results, { }, { :user => {:username => "paul", :role_names => []}, :tag_view => 'untagged' }
    assert_response :success
    get :results, { }, { :user => {:username => "paul", :role_names => []}, :tag_view => 'tag', :tag_which => 'my', :tag_current => 'good' }
    assert_response :success
    get :results, { }, { :user => {:username => "paul", :role_names => []}, :tag_view => 'tag', :tag_which => 'my', :tag_current => 'bad' }
    assert_response :success
    get :results, { }, { :user => {:username => "paul", :role_names => []}, :tag_view => 'tag', :tag_which => 'all', :tag_current => 'good' }
    assert_response :success
  end

  def test_result_count
    post :result_count, { :search => { :result_count => "15" } }
    assert_response :redirect 
    assert_redirected_to :action => "results" 
    assert_equal 15, session[:items_per_page]
  end

  def test_update_sidebar
    post :update_sidebar, { }, { :tag_view => "untagged" }
    assert_response :success
    post :update_sidebar, { }, { :tag_view => "tag", :tag_current => "bad tag" }
    assert_response :success
  end
end
