##########################################################################
# Copyright 2007 Applied Research in Patacriticism and the University of Virginia
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##########################################################################

#require File.expand_path(File.dirname(__FILE__) + '/../../../lib/collex_engine')
module Solr; end
module Solr; module Request; end; end

class Solr::Request::Standard
	attr_reader :p
	def initialize(params)
		@p = params
	end
end

module Solr
	class Response
		attr_reader :hits, :total_hits, :data
		URI = 'uri:http\:\/\/some\/fake\/uri'
		URI2 = 'uri:http\:\/\/some\/fake\/uri2'
		URLS = [URI + ".html"]
		THUMBNAIL = "http://some/fake/uri/img/thumbnail.png"
		USERNAME = "some_user"

		SOLR_DOCUMENT = {"thumbnail" => THUMBNAIL, "uri" => URI, "title"=>["First Title"], "archive"=>"swinburne", "date_label" => ["1865","1890"], "url" => URLS, "genre"=>["Poetry", "Primary"], "year"=>["1865"], "role_AUT" => "Dana Wheeles", "role_EDT" => "Bethany Nowviskie"}

		MLTS = [{"uri"=>"http://rotunda.upress.virginia.edu/Arnold/V3P176D2", "title"=>["Algernon Charles Swinburne to Matthew Arnold"], "archive"=>"rotunda_arnold", "date_label"=>["9 October 1867"], "url"=>["http://rotunda.upress.virginia.edu/Arnold/display.xqy?letter=V3P176D2"], "genre"=>["Primary", "Letters"], "year"=>["1867"], "source"=>["The Letters of Matthew Arnold (ISBN: 0813916518)"], "agent"=>["Algernon Charles Swinburne", "Cecil Y. Lang", "University of Virginia Press"]},
					{"uri"=>"http://rotunda.upress.virginia.edu/Arnold/V3P178D1", "title"=>["Matthew Arnold to Algernon Charles Swinburne"], "archive"=>"rotunda_arnold", "date_label"=>["10 October 1867"], "url"=>["http://rotunda.upress.virginia.edu/Arnold/display.xqy?letter=V3P178D1"], "genre"=>["Primary", "Letters"], "year"=>["1867"], "source"=>["The Letters of Matthew Arnold (ISBN: 0813916518)"], "agent"=>["Matthew Arnold", "Cecil Y. Lang", "University of Virginia Press"]}]

		COLLECTION_INFO = {'users' => ["user_one", "user_two"]}
		def initialize(params)
			@hits = []
			@total_hits = 10
			@data = { 'highlighting' => {}, 'facet_counts' => { 'facet_fields' => { 'freeculture' => [], 'genre' => [], 'archive' => [] } } }
			uri = params[:query]
			if uri == URI || uri == URI2
				@hits.push(SOLR_DOCUMENT)
			else
				puts uri
			end
		end

	end

	class Connection
	  #fixtures :cached_resources, :cached_properties
		def initialize(solr_url)

		end

		def send(req)
			r = Response.new(req.p)
			return r
		end
	end

	class Util
		def self.query_parser_escape(uri)
			# backslash prefix everything that isn't a word character
			return uri.gsub(/(\W)/,'\\\\\1')
		end

		# paired_array_each([key1,value1,key2,value2]) yields twice:
		#     |key1,value1|  and |key2,value2|
		def self.paired_array_each(a, &block)
			0.upto(a.size / 2 - 1) do |i|
				n = i * 2
				yield(a[n], a[n+1])
			end
		end
	end
end