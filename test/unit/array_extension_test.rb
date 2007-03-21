require File.dirname(__FILE__) + '/../test_helper'

class ArrayExtensionTest < Test::Unit::TestCase
  def test_to_hash
    a = ['key', 'value']
    h = a.to_hash
    assert_equal 'value', h['key']
    assert_equal 1, h.size
  end
end