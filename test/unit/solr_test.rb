require File.dirname(__FILE__) + '/../test_helper'

class Solr
  attr_accessor :return_value
  def post_to_solr(body, mode = :search)
    @return_value
  end
end

class SolrTest < Test::Unit::TestCase
  def setup
  end
  
  def test_numdocs
    s = Solr.new
    s.return_value = "{'header'=>{'qtime'=>1},'response'=>{'maxDoc'=>106,'numFound'=>50,'version'=>1170175424488}}"
    assert_equal 50, s.num_docs
  end
  
end
