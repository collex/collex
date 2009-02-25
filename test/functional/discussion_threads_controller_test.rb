require File.dirname(__FILE__) + '/../test_helper'

class DiscussionThreadsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:discussion_threads)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_discussion_thread
    assert_difference('DiscussionThread.count') do
      post :create, :discussion_thread => { }
    end

    assert_redirected_to discussion_thread_path(assigns(:discussion_thread))
  end

  def test_should_show_discussion_thread
    get :show, :id => discussion_threads(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => discussion_threads(:one).id
    assert_response :success
  end

  def test_should_update_discussion_thread
    put :update, :id => discussion_threads(:one).id, :discussion_thread => { }
    assert_redirected_to discussion_thread_path(assigns(:discussion_thread))
  end

  def test_should_destroy_discussion_thread
    assert_difference('DiscussionThread.count', -1) do
      delete :destroy, :id => discussion_threads(:one).id
    end

    assert_redirected_to discussion_threads_path
  end
end
