require File.dirname(__FILE__) + '/test_helper'

class TimedCacheFragmentControllerTest < Test::Unit::TestCase
    
  def setup    
    @controller = CacheTestingController.new    
    @controller.expire_fragment(/#{TEST_CACHE_ROOT}/)
  end
  
  def teardown
    @controller.expire_fragment(/#{TEST_CACHE_ROOT}/)    
  end
  
  def test_cache_timeout
    _erbout = ''
    @controller.cache_timeout(TEST_CACHE_ID, 5.seconds.from_now ) {
      @foo_rendered = true
    }
    
    assert @foo_rendered
    assert !@controller.is_cache_expired?(TEST_CACHE_ID)
    sleep(6)
    assert @controller.is_cache_expired?(TEST_CACHE_ID)
  end
  
  def test_expire_timeout_fragment_regex
    _erbout = ''
    @controller.cache_timeout(TEST_CACHE_ID, 5.hours.from_now ) {}
    @controller.cache_timeout(TEST_CACHE_ID2, 5.hours.from_now ) { }
    
    assert !@controller.is_cache_expired?(TEST_CACHE_ID)
    assert !@controller.is_cache_expired?(TEST_CACHE_ID2)
    @controller.expire_timeout_fragment(/test/)
    assert @controller.is_cache_expired?(TEST_CACHE_ID)
    assert @controller.is_cache_expired?(TEST_CACHE_ID2)
  end

  # TODO need to figure out how to mock url_for properly
  # def test_expire_timeout_fragment_hash
    # _erbout = ''
    #  @controller.cache_timeout( TEST_CACHE_HASH, 5.seconds.from_now ) {
    #    @foo_data = true
    #  }
    #  assert !@controller.is_cache_expired?(TEST_CACHE_HASH)
    #  @controller.expire_timeout_fragment(TEST_CACHE_HASH)
    #  assert @controller.is_cache_expired?(TEST_CACHE_HASH)
  # end

  def test_is_cache_expired?
    _erbout = ''
    assert @controller.is_cache_expired?("invalid key")    
  end
  
end
