require File.dirname(__FILE__) + '/test_helper'

class TimedCacheFragmentViewTest < Test::Unit::TestCase
    
  include ActionView::Helpers::TimedCacheHelper

  def fragment_cache_key(name)
    @controller.fragment_cache_key(name)
  end  
    
  def setup
    @controller = CacheTestingController.new
    @controller.expire_fragment(/#{TEST_CACHE_ROOT}/)
  end

  def teardown
    @controller.expire_fragment(/#{TEST_CACHE_ROOT}/)    
  end
  
  def test_cache_timeout
    _erbout = ''
    cache_timeout(TEST_CACHE_ID, 5.seconds.from_now ) {
      @foo_rendered = true
    }
    
    assert @foo_rendered
    assert !is_cache_expired?(TEST_CACHE_ID)
    sleep(6)
    assert is_cache_expired?(TEST_CACHE_ID)
  end
  
  def test_cache_expired
    assert is_cache_expired?("foo")
  end
end
