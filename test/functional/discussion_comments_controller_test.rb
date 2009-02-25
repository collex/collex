require File.dirname(__FILE__) + '/../test_helper'

class DiscussionCommentsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:discussion_comments)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_discussion_comment
    assert_difference('DiscussionComment.count') do
      post :create, :discussion_comment => { }
    end

    assert_redirected_to discussion_comment_path(assigns(:discussion_comment))
  end

  def test_should_show_discussion_comment
    get :show, :id => discussion_comments(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => discussion_comments(:one).id
    assert_response :success
  end

  def test_should_update_discussion_comment
    put :update, :id => discussion_comments(:one).id, :discussion_comment => { }
    assert_redirected_to discussion_comment_path(assigns(:discussion_comment))
  end

  def test_should_destroy_discussion_comment
    assert_difference('DiscussionComment.count', -1) do
      delete :destroy, :id => discussion_comments(:one).id
    end

    assert_redirected_to discussion_comments_path
  end
end
