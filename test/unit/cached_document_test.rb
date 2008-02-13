require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../test_collex_helper'

class CachedDocumentTest < Test::Unit::TestCase
  
  fixtures :cached_documents, :cached_agents, :cached_documents_genres, :cached_documents_tags, :genres, :tags, :taggings, :agent_types, :interpretations

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

  def test_create_cache_document_array        
    cached_documents = CachedDocument.create_cache_document([URI])
    assert_not_nil cached_documents
    assert_equal 1, cached_documents.size  
  end
  
  # test serialization of a solr document to a cache document
  def test_create_cache_document        
    cached_document = CachedDocument.create_cache_document(URI)
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
  end
  
  def test_save_cached_document
    cached_document = CachedDocument.create_cache_document(URI)
    assert cached_document.save
    from_db = CachedDocument.find_by_uri(URI)
    assert_not_nil from_db
    assert_equal URI, from_db.uri
  end
  
  def test_bad_cache_document
    cached_document = CachedDocument.create_cache_document("non-existant uri")
    assert cached_document.nil?
  end
  
  def test_site_cloud
    cloud = CachedDocument.cloud(:archive)
    assert_not_nil cloud
    names = cloud.map { |c| c[0] }
    assert names.include?(cached_documents(:one).archive)
  end
  
  def test_name_cloud
     cloud = CachedDocument.cloud(:agent_facet)
     assert_not_nil cloud
     names = cloud.map { |c| c[0] }
     assert names.include?(cached_agents(:bob).name)
  end

   def test_cloud_user
      cloud = CachedDocument.cloud( :agent_facet, interpretations(:first).user_id )
      assert_not_nil cloud
      names = cloud.map { |c| c[0] }
      assert names.include?(cached_agents(:bob).name)
   end

   def test_cloud_limit
      cloud = CachedDocument.cloud( :agent_facet, nil, 1 )
      assert_not_nil cloud
      assert( cloud.size <= 1 )

      cloud = CachedDocument.cloud( :agent_facet, nil, "1" )
      assert_not_nil cloud
      assert( cloud.size <= 1 )
   end

   def test_tag_cloud
      cloud = CachedDocument.cloud(:tag)
      assert_not_nil cloud
      names = cloud.map { |c| c[0] }
      assert names.include?(tags(:tag_a).name)
   end
   
   def test_genre_cloud
       cloud = CachedDocument.cloud(:genre)
       assert_not_nil cloud
       names = cloud.map { |c| c[0] }
       assert names.include?(genres(:citation).name)
    end
    
    def test_cloud_list_archive
      list,count = CachedDocument.list_from_cloud_tag( :archive, cached_documents(:one).archive )
      assert_not_nil list
      list.each do |item|
        assert_equal cached_documents(:one).archive, item.archive 
      end
    end

    def test_cloud_list_agent
      list,count = CachedDocument.list_from_cloud_tag( :agent_facet, cached_agents(:bob).name )
      assert_not_nil list
      item = list.first 
      assert_not_nil item
      assert_equal cached_documents(:one).uri, item.uri 
    end

    def test_cloud_list_tag
      list,count = CachedDocument.list_from_cloud_tag( :tag, tags(:tag_a).name )
      assert_not_nil list
      item = list.first 
      assert_not_nil item
      assert_equal cached_documents(:one).uri, item.uri 
    end

    def test_cloud_list_genre
      list,count = CachedDocument.list_from_cloud_tag( :genre, genres(:citation).name )
      assert_not_nil list
      item = list.first 
      assert_not_nil item
      assert_equal cached_documents(:one).uri, item.uri 
    end
        
end
