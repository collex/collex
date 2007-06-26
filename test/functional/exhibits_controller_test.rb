require File.dirname(__FILE__) + '/../test_helper'
require 'exhibits_controller'

# Re-raise errors caught by the controller.
class ExhibitsController; def rescue_action(e) raise e end; end

#TODO need test coverage of edit/update and Paging


# NOTE this test relies on FormTestHelper plugin:
# http://form-test-helper.googlecode.com/svn/form_test_helper
class ExhibitsControllerTest < Test::Unit::TestCase
  fixtures :exhibits, :exhibited_items, :exhibited_sections, :users
  fixtures :licenses, :exhibit_section_types, :exhibit_types

  def setup
    @controller = ExhibitsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @exhibit = exhibits(:dang)
    @owner = users(:exhibit_owner)
    @viewer = users(:exhibit_viewer)
    @request.session[:user] = {:username => @owner.username}
  end

  def test_sanity
    assert(true)
  end
#   
#   def test_gets_index_as_sanity_check
#     get(:index)
#     assert_response(:success)
#     assert(assigns(:exhibits), "Should have assigned :exhibits")
#   end

  def test_edit_update_delete_bad_exhibit_id_redirects_to_login_when_not_logged_in
    @request.session[:user] = nil
    get(:edit, :id => -1)
    assert_redirected_to(:action => "login", :controller => "login")
    put(:update, :id => -1)
    assert_redirected_to(:action => "login", :controller => "login")
    delete(:destroy, :id => -1)
    assert_redirected_to(:action => "login", :controller => "login")
  end
  
  def test_necrud_exhibit_redirects_to_login_when_not_logged_in #necrud: new edit create update delete
    @request.session[:user] = nil
    assertions = proc do 
      assert_redirected_to(:action => "login", :controller => "login")
    end
    get(:new)
    assertions.call
    get(:edit, :id => @exhibit.id)
    assertions.call
    post(:create)
    assertions.call
    put(:update, :id => @exhibit.id)
    assertions.call
    delete(:destroy, :id => @exhibit.id)
    assertions.call
  end
  
#   def test_can_necrd_when_logged_in
#     # updates are done via ajax
#     assertions = proc do |response|
#       assert_response(response)
#       assert(exhibit = assigns(:exhibit), "Should have assigned :exhibit")
#       assert(exhibit.errors.empty?, "@exhibit should not have errors: #{exhibit.errors.inspect}")
#     end
#     exhibit_count = Exhibit.count
#     get(:new)
#     assertions.call(:success)
#     submit_form('new_exhibit') do |f|
#       f.exhibit.title = "New Exhibit"
#       f.exhibit.exhibit_type_id = 1
#       f.exhibit.license_id = 1
#       f.exhibit.annotation = "Exhibit notes."
#     end
#     assert_equal(exhibit_count += 1, Exhibit.count )
#     assertions.call(:redirect)
#     assert_redirected_to(edit_exhibit_path(assigns(:exhibit)))
#     assert(flash[:notice])
#     
#     get(:edit, :id => @exhibit.id)
#     assertions.call(:success)
# 
#     delete(:destroy, :id => @exhibit.id)   
#     assert_equal(exhibit_count -= 1, Exhibit.count )
#     assert_response(:redirect)
#     assert_redirected_to(exhibits_path)
#   end
  
  def test_edit_bad_exhibit_id_redirects_to_index_with_warning_when_logged_in
    get(:edit, :id => -1)
    assert_redirected_to(exhibits_path)
    assert_not_nil(flash[:warning])
  end
  
  def test_can_share_exhibit
    post(:share, :id => @exhibit.id)
    assert(exhibit = assigns(:exhibit), "@exhibit should have been assigned")
    assert(exhibit.shared?, "Exhibit should be shared.")
    assert_response(:redirect)
    assert_redirected_to(:action => "index")
  end
  
  def test_can_unshare_exhibit
    @exhibit.share!
    assert(@exhibit.save)
    post(:unshare, :id => @exhibit.id)
    assert(exhibit = assigns(:exhibit), "@exhibit should have been assigned")
    assert(!exhibit.shared?, "Exhibit should be unshared.")
    assert_response(:redirect)
    assert_redirected_to(:action => "index")
  end
  
  def test_can_publish_exhibit
    @exhibit.share!
    assert(@exhibit.save)
    post(:publish, :id => @exhibit.id)
    assert(exhibit = assigns(:exhibit), "@exhibit should have been assigned")
    assert(exhibit.published?, "Exhibit should be published.")
    assert_response(:redirect)
    assert_redirected_to(:action => "index")
  end
  
  def test_non_owner_and_non_admin_cannot_share_unshare_or_publish
    @request.session[:user] = {:username => @viewer.username}
    post(:share, :id => @exhibit.id)
    assert(exhibit = assigns(:exhibit), "@exhibit should have been assigned")
    assert(!exhibit.shared?, "Exhibit should not have been shared.")
    assert_response(:redirect)
    assert_redirected_to(:action => "index")
    
    @exhibit.share!
    @exhibit.save!
    post(:unshare, :id => @exhibit.id)
    assert(exhibit = assigns(:exhibit), "@exhibit should have been assigned")
    assert(exhibit.shared?, "Exhibit should not have been unshared.")
    assert_response(:redirect)
    assert_redirected_to(:action => "index")
    
    
    post(:publish, :id => @exhibit.id)
    assert(exhibit = assigns(:exhibit), "@exhibit should have been assigned")
    assert(!exhibit.published?, "Exhibit should not have been published.")
    assert_response(:redirect)
    assert_redirected_to(:action => "index")
  end
end
