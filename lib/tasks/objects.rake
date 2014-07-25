##########################################################################
# Copyright 2011 Applied Research in Patacriticism and the University of Virginia
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

namespace :objects do

	desc "Find all references to southey objects."
	task :all_southey => :environment do
		puts "~~~~~~~~~~~ Looking for all uses of collected southey objects..."
		start_time = Time.now()
		all = CachedResource.all
		cr_southey = []
		all.each {|cr|
			if cr.uri.include?("http://www.rc.umd.edu/editions/southey_letters")
				cr_southey.push(cr)
			end
		}
		puts "Total objects: #{cr_southey.length}"

		cr_southey.each { |cr|
			puts "Item: #{cr.uri}"
			recs = CollectedItem.where({cached_resource_id: cr.id})
			recs.each {|rec|
				user = User.find(rec.user_id)
				puts "    User: #{user.id}.#{user.username} collected"
			}

			recs = DiscussionComment.where({cached_resource_id: cr.id})
			recs.each {|rec|
				puts "    Discussion comment #{rec.id}"
			}

			recs = Tagassign.where({cached_resource_id: cr.id})
			recs.each {|rec|
				tag = Tag.find(rec.tag_id)
				puts "    Tag #{tag.name}"
			}
		}

		finish_line(start_time)
	end

	desc "Removes all references to Southey in collected objects and tags"
	task :remove_southey => :environment do
		puts "~~~~~~~~~~~ Deleting all uses of collected southey objects..."
		#target_user_id = 623
		start_time = Time.now()
		all = CachedResource.all
		cr_southey = []
		all.each {|cr|
			if cr.uri.include?("http://www.rc.umd.edu/editions/southey_letters")
				cr_southey.push(cr)
			end
		}
		puts "Total objects: #{cr_southey.length}"

		cr_southey.each { |cr|
			puts "Item: #{cr.uri}"
			found_one = false
			recs = CollectedItem.where({cached_resource_id: cr.id})
			recs.each {|rec|
				#if rec.user_id == target_user_id
					rec.destroy()
					print "x"
#				else
#					user = User.find(rec.user_id)
#					puts "    User: #{user.id}. #{user.username} collected"
#					found_one = true
#				end
			}

			recs = DiscussionComment.where({cached_resource_id: cr.id})
			recs.each {|rec|
				puts "    Discussion comment #{rec.id}"
				found_one = true
			}

			recs = Tagassign.where({cached_resource_id: cr.id})
			recs.each {|rec|
#				if rec.user_id == target_user_id
					rec.destroy()
					print "x"
#				else
#					user = User.find(rec.user_id)
#					tag = Tag.find(rec.tag_id)
#					puts "    Tag #{tag.name} by #{user.id}. #{user.username}"
#					found_one = true
#				end
			}

			if found_one == false
				cr.destroy()
			end
		}

		finish_line(start_time)

	end
end