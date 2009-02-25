require File.dirname(__FILE__) + '/../test_helper'

class DiscussionTopicsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:discussion_topics)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_discussion_topic
    assert_difference('DiscussionTopic.count') do
      post :create, :discussion_topic => { }
    end

    assert_redirected_to discussion_topic_path(assigns(:discussion_topic))
  end

  def test_should_show_discussion_topic
    get :show, :id => discussion_topics(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => discussion_topics(:one).id
    assert_response :success
  end

  def test_should_update_discussion_topic
    put :update, :id => discussion_topics(:one).id, :discussion_topic => { }
    assert_redirected_to discussion_topic_path(assigns(:discussion_topic))
  end

  def test_should_destroy_discussion_topic
    assert_difference('DiscussionTopic.count', -1) do
      delete :destroy, :id => discussion_topics(:one).id
    end

    assert_redirected_to discussion_topics_path
  end
end
