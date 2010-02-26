# ------------------------------------------------------------------------
#     Copyright 2009 Applied Research in Patacriticism and the University of Virginia
# 
#     Licensed under the Apache License, Version 2.0 (the "License");
#     you may not use this file except in compliance with the License.
#     You may obtain a copy of the License at
# 
#         http://www.apache.org/licenses/LICENSE-2.0
# 
#     Unless required by applicable law or agreed to in writing, software
#     distributed under the License is distributed on an "AS IS" BASIS,
#     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#     See the License for the specific language governing permissions and
#     limitations under the License.
# ----------------------------------------------------------------------------

class SearchUserContent
	def initialize

	end

	# The results depend on what is visible to the user. We want hits where:
	#Exhibits/Groups/Clusters are only visible on one of the three page types, depending on whether it is peer-reviewed, community, or classroom.
	#
	#Exhibits:
	#- if it is not in a group, it is visible if it is shared.
	#- if it is in a community or classroom group, it is visible if it is shared with the web, or the user is a member of the group and it is shared to the group, or the user is an admin of the group and it is shared with the admins.
	#- if it is in a peer-reviewed group, it has the same rules as the community groups, but it is NOT visible if it is pending peer-review.
	#
	#(Note that if the exhibit is owned by the user, it isn't automatically visible. It still has to meet the criteria above.)
	#
	#Groups
	#- All Groups are always visible
	#
	#Clusters
	#- visible if cluster is shared to web
	#- visible if user is a member and cluster is shared to group
	#- visible if user is a group admin and cluster is shared to group admins
	#
	#Note:
	#- groups are explicitly given peer-reviewed/community/classroom type.
	#- clusters have the same type as the group they are in.
	#- Exhibits that are in groups have the same type as the group they are in.
	#- Exhibits that are not in a group are given the Community type unless the NINES administrator overrides that.

	def find_objects(options)
		# returns: { total_hits => int, num_pages => int, hits => [ ActiveRecord: Exhibit,Cluster,Group ] }
		# input parameters:
		facet_exhibit = options[:facet][:exhibit]	# bool
		facet_cluster = options[:facet][:cluster]	# bool
		facet_group = options[:facet][:group]	# bool
		facet_federation = options[:facet][:federation]	#bool
		facet_section = options[:facet][:section]	# symbol -- enum: classroom|community|peer-reviewed
		user_id = options[:user_id]	# int
		search_terms = options[:terms]	# array of strings, they are ANDed
		sort_by = options[:sort_by]	# symbol -- enum: relevancy|title|most_recent
		page = options[:page]	# int
		page_size = options[:page_size]	#int

		# TODO-PER: stub
		# getting hits
		hits = []
		if facet_exhibit
			hits += Exhibit.all
		end
		if facet_cluster
			hits += Cluster.all
		end
		if facet_group
			hits += Group.all
		end

		# sorting hits
		if sort_by != :relevancy
			hits.sort! { |a,b|
				if sort_by == :title
					get_title(a).downcase <=> get_title(b).downcase
				else
					a.updated_at <=> b.updated_at
				end
			}
		end

		# paginating hits
		total_hits = hits.length
		num_pages = (total_hits / page_size).ceil
		hits = hits.slice(page*page_size, page_size)

		# return
		{ :total_hits => total_hits, :num_pages => num_pages, :hits => hits }
	end

	def index_object(object)
		# object is an ActiveRecord of type Group, Cluster, or Exhibit
	end

	private
	def get_title(object)
		if object.kind_of? Exhibit
			return object.title
		elsif object.kind_of? Group
			return object.name
		elsif object.kind_of? Cluster
			return object.name
		else
			return ''
		end
	end
end
