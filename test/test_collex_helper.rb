
# sets up mock collex engine for testing collex dependent units
module TestCollexHelper
#  URI = "http://some/fake/uri"
#  URI2 = "http://some/fake/uri2"
#  URLS = [URI + ".html"]
#  THUMBNAIL = "http://some/fake/uri/img/thumbnail.png"
#  USERNAME = "some_user"
#
#  SOLR_DOCUMENT = {"thumbnail" => THUMBNAIL, "uri" => URI, "title"=>["First Title"], "archive"=>"swinburne", "date_label" => ["1865","1890"], "url" => URLS, "genre"=>["Poetry", "Primary"], "year"=>["1865"], "role_AUT" => "Dana Wheeles", "role_EDT" => "Bethany Nowviskie"}
#
#  MLTS = [{"uri"=>"http://rotunda.upress.virginia.edu/Arnold/V3P176D2", "title"=>["Algernon Charles Swinburne to Matthew Arnold"], "archive"=>"rotunda_arnold", "date_label"=>["9 October 1867"], "url"=>["http://rotunda.upress.virginia.edu/Arnold/display.xqy?letter=V3P176D2"], "genre"=>["Primary", "Letters"], "year"=>["1867"], "source"=>["The Letters of Matthew Arnold (ISBN: 0813916518)"], "agent"=>["Algernon Charles Swinburne", "Cecil Y. Lang", "University of Virginia Press"]},
#        {"uri"=>"http://rotunda.upress.virginia.edu/Arnold/V3P178D1", "title"=>["Matthew Arnold to Algernon Charles Swinburne"], "archive"=>"rotunda_arnold", "date_label"=>["10 October 1867"], "url"=>["http://rotunda.upress.virginia.edu/Arnold/display.xqy?letter=V3P178D1"], "genre"=>["Primary", "Letters"], "year"=>["1867"], "source"=>["The Letters of Matthew Arnold (ISBN: 0813916518)"], "agent"=>["Matthew Arnold", "Cecil Y. Lang", "University of Virginia Press"]}]
#
#  COLLECTION_INFO = {'users' => ["user_one", "user_two"]}
#
#  class CollexEngine
#    def objects_for_uris(uris, user=nil)
#      if(uris == [URI])
#        [SOLR_DOCUMENT]
#      else
#        []
#      end
#    end
#    def object_detail(objid, user)
#      document = SOLR_DOCUMENT
#      mlt = MLTS
#      collection_info = COLLECTION_INFO
#
#      if(objid == URI || objid == URI2 || objid == 'http://resource/1/paul' || objid == 'http://resource/2/dave' || objid == 'http://resource/4/paul_untagged')
#        return [document, mlt, collection_info]
#      else
#        return [nil, nil, nil]
#      end
#    end
#  end
#
#  def SolrResource.solr
#    CollexEngine.new
#  end
end
