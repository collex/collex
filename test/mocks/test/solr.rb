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
	def initialize(params)
		@p = params
	end
end

module Solr
	class Response
		attr_reader :hits, :total_hits, :data
		def initialize
			@hits = []
			@total_hits = 10
			@data = { 'highlighting' => {}, 'facet_counts' => { 'facet_fields' => { 'freeculture' => [], 'genre' => [], 'archive' => [] } } }
		end

	end

	class Connection
	  #fixtures :cached_resources, :cached_properties
		def initialize(solr_url)

		end

		def send(req)
			r = Response.new()
			return r
		end
	end

	class Utils
		def self.query_parser_escape(uri)
			# backslash prefix everything that isn't a word character
			string.gsub(/(\W)/,'\\\\\1')
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