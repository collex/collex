##########################################################################
# Copyright 2009 Applied Research in Patacriticism and the University of Virginia
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

class ObjectActivity < ActiveRecord::Base
	def self.record_collect(user, uri)
		ObjectActivity.create({ :username => user.username, :action => 'collect', :uri => uri, :tagname => nil })
	end

	def self.record_uncollect(user, uri)
		ObjectActivity.create({ :username => user.username, :action => 'uncollect', :uri => uri, :tagname => nil })
	end

	def self.record_tag(user, uri, tag)
		ObjectActivity.create({ :username => user.username, :action => 'tag', :uri => uri, :tagname => tag })
	end

	def self.record_untag(user, uri, tag)
		ObjectActivity.create({ :username => user.username, :action => 'untag', :uri => uri, :tagname => tag })
	end

	def self.get_stats()
		day = 1.day.ago
		week = 1.week.ago
		month = 30.days.ago
		year = 1.year.ago
		objects_collected_today = self.num_recs('collect', day)
		objects_collected_this_week = self.num_recs('collect', week)
		objects_collected_this_month = self.num_recs('collect', month)
		objects_collected_this_year = self.num_recs('collect', year)
		objects_tagged_today = self.num_recs('tag', day)
		objects_tagged_this_week = self.num_recs('tag', week)
		objects_tagged_this_month = self.num_recs('tag', month)
		objects_tagged_this_year = self.num_recs('tag', year)
		num_users_with_tags = self.get_num_uniq_users('tag')
		ave_num_tags_per_user = num_users_with_tags > 0 ? self.get_total('tag') / num_users_with_tags : 0
		num_users_with_collect = self.get_num_uniq_users('collect')
		ave_num_collect_per_user = num_users_with_collect > 0 ? self.get_total('collect') / num_users_with_collect : 0

		# TODO-PER: The commented code below will return the tags for the entire history of the site, but it is really slow. Figure out a faster way to do this.
#		all_collected = CollectedItem.all()
#		all_tagassigns = Tagassign.all()
#		user_tags = {}
#		all_tagassigns.each { |tag|
#			user_id = tag.collected_item.user_id
#			user_tags[user_id] = true
#		}
#
#		user_coll = {}
#		all_collected.each { |coll|
#			user_coll[coll.user_id] = true
#		}

		return { :objects_collected_today => objects_collected_today, :objects_collected_this_week => objects_collected_this_week,
			:objects_collected_this_month => objects_collected_this_month, :objects_collected_this_year => objects_collected_this_year,
			:objects_tagged_today => objects_tagged_today, :objects_tagged_this_week => objects_tagged_this_week,
			:objects_tagged_this_month => objects_tagged_this_month, :objects_tagged_this_year => objects_tagged_this_year,

			:num_users_with_tags => num_users_with_tags, :ave_num_tags_per_user => ave_num_tags_per_user,
			:num_users_with_collect => num_users_with_collect, :ave_num_collect_per_user => ave_num_collect_per_user
#			:num_users_with_tags => user_tags.length, :ave_num_tags_per_user => user_tags.length > 0 ? all_tagassigns.length / user_tags.length : 0,
#			:num_users_with_collect => user_coll.length, :ave_num_collect_per_user => user_coll.length > 0 ? all_collected.length / user_coll.length : 0
		}
	end

	def self.get_archive_stats()
		# this returns the number of tags and collects broken down by archive
		recs = ObjectActivity.all(:conditions => [ 'updated_at > ?', 1.year.ago])
		stats = { }
		recs.each { |rec|
			cr = CachedResource.find_by_uri(rec.uri)
			if cr
				cp = CachedProperty.find_by_cached_resource_id_and_name(cr.id, 'archive')
				if cp
					archive = cp['value']
				else
					archive = "RESOURCE NOT FOUND"
				end
			else
				archive = "RESOURCE NOT FOUND"
			end
			stats[archive] = { :collect => 0, :tag => 0 } if stats[archive] == nil
			stats[archive][:collect] += 1 if rec['action'] == 'collect'
			stats[archive][:tag] += 1 if rec['action'] == 'tag'
		}
		return stats
	end

	private
	def self.num_recs(action, period)
		recs = ObjectActivity.all(:conditions => [ 'action = ? AND updated_at > ?', action,  period])
		return recs.length
	end

	def self.get_num_uniq_users(action)
		recs = ObjectActivity.all(:conditions => [ 'action = ?', action])
		results = {}
		recs.each { |rec| results[rec.username] = true }
		return results.length
	end

	def self.get_total(action)
		recs = ObjectActivity.all(:conditions => [ 'action = ?', action])
		return recs.length
	end
end
