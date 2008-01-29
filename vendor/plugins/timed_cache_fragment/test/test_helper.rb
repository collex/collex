require 'test/unit'
RAILS_ENV = 'test'
require File.expand_path(File.join(File.dirname(__FILE__), '../../../../config/environment.rb'))
require 'action_controller/test_process'
require 'breakpoint'

TEST_CACHE_ROOT = "timed_fragment_cache_test"
TEST_CACHE_ID = "timed_fragment_cache_test/foo"
TEST_CACHE_ID2 = "timed_fragment_cache_test/bar"
TEST_CACHE_HASH = { :controller => 'timed_fragment_cache_test', :action => 'bar' }

class CacheTestingController < ActionController::Base

  # force caching so we can test it
  def perform_caching
    true
  end

end
