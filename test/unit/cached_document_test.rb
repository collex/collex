require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../test_collex_helper'

class CachedDocumentTest < Test::Unit::TestCase
  
  fixtures :cached_documents, :cached_agents, :cached_documents_genres, :cached_documents_tags, :genres, :tags, :agent_types

  include TestCollexHelper
  
  # should contain a uri
  def test_uri
    cached_document = CachedDocument.find(cached_documents(:one).id)
    assert_equal cached_documents(:one).uri, cached_document.uri     
  end
  
  # should be able to access a list of agents
  def test_agents
    cached_document = CachedDocument.find(cached_documents(:one).id)
    assert cached_document.cached_agents.include?(cached_agents(:bob))
    assert cached_document.cached_agents.include?(cached_agents(:joe))    
  end
  
  # should be able to access a list of genres
  def test_genres
    cached_document = CachedDocument.find(cached_documents(:one).id)
    assert cached_document.genres.include?(genres(:citation))
    assert cached_document.genres.include?(genres(:poetry))
  end
  
  # should be able to access a list of tags
  def test_tags
    cached_document = CachedDocument.find(cached_documents(:one).id)
    assert cached_document.tags.include?(tags(:tag_a))
    assert cached_document.tags.include?(tags(:tag_b))    
  end
  
  def test_add_cached_agent    
    cached_agent = CachedAgent.new
    cached_agent.name = "bob"
    cached_agent.agent_type = AgentType.find_by_name( agent_types(:author).name )
    assert cached_agent.save
    cached_document = CachedDocument.find(cached_documents(:one).id)
    cached_document.cached_agents << cached_agent
    assert cached_document.save
    cached_document = CachedDocument.find(cached_documents(:one).id)
    agent_types = cached_document.cached_agents.map { |agent| agent.agent_type.name }
    assert agent_types.include?(agent_types(:author).name)
  end
  
  # test serialization of a solr document to a cache document
  def test_cache_document        
    cached_document = CachedDocument.cache_document(URI)
    assert !cached_document.nil?
    assert_equal URI, cached_document.uri
    assert_equal SOLR_DOCUMENT["title"].first, cached_document.title
    assert_equal SOLR_DOCUMENT["date_label"].join('; '), cached_document.date_label
    assert_equal SOLR_DOCUMENT["archive"], cached_document.archive
    agent_names = cached_document.cached_agents.map { |agent| agent.name }
    assert agent_names.include?(SOLR_DOCUMENT["role_AUT"])
    assert agent_names.include?(SOLR_DOCUMENT["role_EDT"])
    agent_types = cached_document.cached_agents.map { |agent| agent.agent_type.name }
    assert agent_types.include?("AUT")
    assert agent_types.include?("EDT")  
    genre_names = cached_document.genres.map { |genre| genre.name }
    assert genre_names.include?(SOLR_DOCUMENT["genre"].first)
    from_db = CachedDocument.find_by_uri(URI)
    assert_equal URI, from_db.uri
  end
  
  def test_bad_cache_document
    cached_document = CachedDocument.cache_document("non-existant uri")
    assert cached_document.nil?
  end
end
