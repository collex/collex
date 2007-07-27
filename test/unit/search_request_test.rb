require File.dirname(__FILE__) + '/../test_helper'

class SearchRequestTest < Test::Unit::TestCase
  def test_it
    req = SearchRequest.new(:field_list => "foo", :facet_fields => ["bar"])
    
    assert_equal "foo", req.to_hash[:fl]
    assert_equal ["bar"], req.to_hash[:ff]
  end
end