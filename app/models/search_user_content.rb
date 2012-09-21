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

class SearchUserContent < ActiveRecord::Base

	# The results depend on what is visible to the user. We want hits where:
	#Exhibits/Groups/Clusters are only visible on one of the three page types, depending on whether it is peer-reviewed, community, or classroom.
	#
	#Exhibits:
	#- if it is not in a group, it is visible if it is shared.
	#- if it is in a community or classroom group, it is visible if it is shared with the web, or the user is a member of the group and it is
  #     shared to the group, or the user is an admin of the group and it is shared with the admins.
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
	#- Exhibits that are not in a group are given the Community type unless the Collex administrator overrides that.

	def find_objects(options)
		# returns: { total_hits => int, num_pages => int, hits => [ ActiveRecord: Exhibit,Cluster,Group ] }

		user_id = options[:user_id]	# int
		member = Group.get_all_users_groups(user_id)
		admin = Group.get_all_users_admins(member, user_id)
		options[:member] = member
		options[:admin] = admin

		@solr = Catalog.factory_create_user() if @solr == nil
		ret = @solr.search_user_content(options)
		hits = []
		# We have to be careful: an object can be deleted and still be in the index until the next reindexing
		ret[:hits].each {|hit|
			case hit['object_type']
			when 'Exhibit' then
				rec = Exhibit.find_by_id(hit['object_id'])
				hits.push({ :obj => rec, :last_modified => hit['last_modified'], :text => hit['text'] }) if rec
			when 'Group' then
				rec = Group.find_by_id(hit['object_id'])
				hits.push({ :obj => rec, :last_modified => hit['last_modified'], :text => hit['text'] }) if rec
			when 'Cluster' then
				rec = Cluster.find_by_id(hit['object_id'])
				hits.push({ :obj => rec, :last_modified => hit['last_modified'], :text => hit['text'] }) if rec
			when 'DiscussionThread' then
				rec = DiscussionThread.find_by_id(hit['object_id'])
				hits.push({ :obj => rec, :last_modified => hit['last_modified'], :text => hit['text'] }) if rec
			end
		}
		page_size = options[:page_size]	#int

		total_hits = ret[:total_hits]
		num_pages = ((0.0 + total_hits) / page_size).ceil

		return { :total_hits => total_hits, :total => ret[:total], :num_pages => num_pages, :hits => hits }
	end

#	def format_date(d)
#		str = "#{d}"
#		str = str.gsub(" UTC", "Z")
#		str = str.gsub(" ", "T")
#
#		return str
#	end
#
#	def add_object(object_type, id, federation, section, title, text, last_modified, visibility_type, group_id)
#		doc = { :key => "#{object_type}_#{id}", :object_type => object_type, :object_id => id, :federation => federation,
#			:section => section, :title => title, :title_sort => title, :text => text, :last_modified => format_date(last_modified)
#		}
#		if group_id != nil && group_id.to_i > 0
#			doc[:group_id] = group_id
#		end
#
#		if visibility_type == 'everyone'
#			doc[:visible_to_everyone] = true
#		else
#			doc[:visible_to_everyone] = false
#			if visibility_type == 'member'
#				doc[:visible_to_group_member] = group_id
#			else
#				doc[:visible_to_group_admin] = group_id
#			end
#		end
#		@solr = factory_create_user() if @solr == nil
#		@solr.add_object(doc)
#	end

	# the entry points for the delayed tasks. This takes a string with the type of object and the id of that object.
	def self.index(type, id)
		start_time = Time.now
		#Delayed::Worker.logger.warn("LOG:UserContentIndexing at #{start_time}")
		suc = SearchUserContent.new

		case type
			when 'exhibit'
				obj = Exhibit.find_by_id(id)
				title = obj.title
				suc.reindex_exhibit(obj)
			when 'group'
				obj = Group.find_by_id(id)
				title = obj.name
				suc.reindex_group(obj)
			when 'cluster'
				obj = Cluster.find_by_id(id)
				title = obj.name
				suc.reindex_cluster(obj)
			when 'thread'
				obj = DiscussionThread.find_by_id(id)
				title = obj.get_title()
				suc.reindex_thread(obj)
		end

		suc.commit()

		num_objs = suc.num_objs()
		duration = Time.now - start_time
		SearchUserContent.create!({:last_indexed => Time.now, :obj_type => "#{type}:#{id} #{title}", :seconds_spent_indexing => duration, :objects_indexed => num_objs})
	end

	def commit()
		@solr = Catalog.factory_create_user() if @solr == nil
		@solr.local_commit()
	end

	def num_objs()
		@solr = Catalog.factory_create_user() if @solr == nil
		return @solr.total_user_content()
	end

	def reindex_exhibit(exhibit)
		if exhibit.is_published != 0
			if exhibit.group_id == nil
				section = 'community'
				visibility_type = 'everyone'
				visibility_id = 0
			else
				group = Group.find(exhibit.group_id)
				section = group.group_type
				section = 'community' if section == 'peer-reviewed' && exhibit.is_published == 5
				visibility_type = Group.get_exhibit_visibility(exhibit)
				visibility_id = group.id
			end
			@solr = Catalog.factory_create_user() if @solr == nil
			@solr.add_local_object("Exhibit", exhibit.id, Setup.site_name(), section, exhibit.title, exhibit.get_all_text(), exhibit.last_change, visibility_type, visibility_id)
		else
			@solr = Catalog.factory_create_user() if @solr == nil
			@solr.remove_local_object("Exhibit", exhibit.id, Setup.site_name())
		end
	end

	def reindex_group(group)
		section = group.group_type == 'peer-reviewed' ? 'community' : group.group_type
		@solr = Catalog.factory_create_user() if @solr == nil
		@solr.add_local_object("Group", group.id, Setup.site_name(), section, group.name, Exhibit.strip_tags(group.description), group.updated_at, 'everyone', group.id)
	end

	def reindex_cluster(cluster)
		group = Group.find(cluster.group_id)
		section = group.group_type == 'peer-reviewed' ? 'community' : group.group_type
		@solr = Catalog.factory_create_user() if @solr == nil
		@solr.add_local_object("Cluster", cluster.id, Setup.site_name(), section, cluster.name, Exhibit.strip_tags(cluster.description), cluster.updated_at, cluster.visibility, group.id)
	end

	def reindex_thread(thread)
		# TODO-PER: there are different rules for how visibility is done for forums
		visibility = Group.get_discussion_visibility(thread)
		group_id = thread.group_id
		if group_id == nil || group_id == 0
			section = 'community'
		else
			group = Group.find(group_id)
			section = group.group_type
		end
		text = ""
		comments = thread.discussion_comments
		comments.each {|comment|
			text += Exhibit.strip_tags(comment.comment) + "\n"
		}
		section = section == 'peer-reviewed' ? 'community' : section
		@solr = Catalog.factory_create_user() if @solr == nil
		@solr.add_local_object("DiscussionThread", thread.id, Setup.site_name(), section, thread.title, text, thread.updated_at, visibility, group_id)
	end

	def reindex_all()
		start_time = Time.now
		@solr = Catalog.factory_create_user()
		@solr.start_reindex()

		exhibits = Exhibit.all
		exhibits.each {|exhibit|
			reindex_exhibit(exhibit)
		}

		groups = Group.all
		groups.each {|group|
			reindex_group(group)
		}

		clusters = Cluster.all
		clusters.each {|cluster|
			reindex_cluster(cluster)
		}

		threads = DiscussionThread.all
		threads.each {|thread|
			reindex_thread(thread)
		}

		@solr.local_commit()
		duration = Time.now - start_time
		return duration
	end

	#def reindex_new(tim)
	#	start_time = Time.now
	#	@solr = Catalog.factory_create_user()
	#
	#	exhibits = Exhibit.all(:conditions => [ 'updated_at > ?', tim ] )
	#	exhibits.each {|exhibit|
	#		begin
	#			reindex_exhibit(exhibit)
	#		rescue Exception => e
	#			puts "Error indexing Exhibit #{exhibit.id}: #{e.to_s}"
	#		end
	#	}
	#
	#	groups = Group.all(:conditions => [ 'updated_at > ?', tim ] )
	#	groups.each {|group|
	#		begin
	#			reindex_group(group)
	#		rescue Exception => e
	#			puts "Error indexing Group #{group.id}: #{e.to_s}"
	#		end
	#	}
	#
	#	clusters = Cluster.all(:conditions => [ 'updated_at > ?', tim ] )
	#	clusters.each {|cluster|
	#		begin
	#			reindex_cluster(cluster)
	#		rescue Exception => e
	#			puts "Error indexing Cluster #{cluster.id}: #{e.to_s}"
	#		end
	#	}
	#
	#	threads = DiscussionThread.all(:conditions => [ 'updated_at > ?', tim ] )
	#	threads.each {|thread|
	#		begin
	#			reindex_thread(thread)
	#		rescue Exception => e
	#			puts "Error indexing Discussion #{thread.id}: #{e.to_s}"
	#		end
	#	}
	#
	#	@solr.local_commit()
	#	duration = Time.now - start_time
	#	return duration
	#end

	#def self.last_update()
	#	last_update = nil
	#
	#	# now see if any tables were updated since then
	#	recs = Group.all(:limit => 1, :order => "updated_at DESC")
	#	if recs.length != 0
	#		t = recs[0].updated_at
	#		last_update = t if last_update == nil || last_update < t
	#	end
	#
	#	recs = Cluster.all(:limit => 1, :order => "updated_at DESC")
	#	if recs.length != 0
	#		t = recs[0].updated_at
	#		last_update = t if last_update < t
	#	end
	#
	#	recs = Exhibit.all(:limit => 1, :order => "updated_at DESC")
	#	if recs.length != 0
	#		t = recs[0].updated_at
	#		last_update = t if last_update < t
	#	end
	#
	#	recs = DiscussionComment.all(:limit => 1, :order => "updated_at DESC")
	#	if recs.length != 0
	#		t = recs[0].updated_at
	#		last_update = t if last_update < t
	#	end
	#	return last_update
	#end

	#def self.periodic_update
	#	recs = SearchUserContent.all(:limit => 1, :order => "last_indexed DESC")
	#	last_change = SearchUserContent.last_update()
	#	if recs.blank? || recs.length == 0 || last_change.blank?
	#		is_dirty = true
	#	else
	#		last_index = recs[0].last_indexed
	#		is_dirty = last_index == nil ? false : last_change > last_index
	#	end
	#	if is_dirty
	#		suc = SearchUserContent.new
	#		if recs.blank? || recs.length == 0
	#			duration = suc.reindex_all()
	#		else
	#			duration = suc.reindex_new(recs[0].last_indexed)
	#		end
	#		begin
	#			num_objs = Catalog.factory_create_user().total_user_content()
	#			SearchUserContent.create({ :last_indexed => last_change, :seconds_spent_indexing => duration, :objects_indexed => num_objs })
	#		rescue Catalog::Error => e
	#			num_objs = e.message
	#		end
	#		return { :activity => true, :message => "User Content reindexed on #{last_change}. Time spent indexing: #{duration} seconds, Number of objects: #{num_objs}" }
	#	end
	#	return { :activity => false }
	#end

	#private
	#def get_title(object)
	#	if object.kind_of? Exhibit
	#		return object.title
	#	elsif object.kind_of? Group
	#		return object.name
	#	elsif object.kind_of? Cluster
	#		return object.name
	#	elsif object.kind_of? DiscussionThread
	#		return object.get_title()
	#	else
	#		return ''
	#	end
	#end
end
