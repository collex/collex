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

class DiscussionThread < ActiveRecord::Base
  belongs_to :discussion_topic
	belongs_to :group
	belongs_to :cluster
  has_many :discussion_comments, :order => :position
#	has_and_belongs_to_many :users
	after_save :handle_solr

	def handle_solr
		SearchUserContent.delay.index('thread', self.id)
	end

  def get_title
    if title && title.length > 0
      return title
    end

	if discussion_comments.length == 0
		return "No title"
	end
    ty = discussion_comments[0].get_type()
    case ty
      when "comment" then
        return title
      when "nines_object" then
        hit = CachedResource.get_hit_from_resource_id(discussion_comments[0].cached_resource_id)
        return CGI.escapeHTML(hit["title"]) if hit != nil && hit["title"]
        return "object" # If the object isn't found in the cache or is somehow not complete.
      when "nines_exhibit" then
        exhibit = Exhibit.find(discussion_comments[0].exhibit_id)
        return CGI.escapeHTML(exhibit.title)
      when "inet_object" then
        return discussion_comments[0].link_url
    end
  end

	def get_most_recent_comment_time
		return 0 if discussion_comments.length == 0
		return discussion_comments[discussion_comments.length-1].updated_at
	end

	def self.sort_by_time(threads)
		threads = threads.sort {|a,b|
			a1 = a.discussion_comments.blank? ? Time.at(0) : a.discussion_comments[a.discussion_comments.length-1].updated_at
			b1 = b.discussion_comments.blank? ? Time.at(0) : b.discussion_comments[b.discussion_comments.length-1].updated_at
			b1 <=> a1
		}
		return threads
	end
end
