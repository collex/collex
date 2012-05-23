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

class Cluster < ActiveRecord::Base
	has_many :exhibits
	has_many :discussion_threads
	belongs_to :group
  belongs_to :image#, :dependent=>:destroy
	after_save :handle_solr

	def handle_solr
		SearchUserContent.delay.index('cluster', self.id)
	end

	def get_visibility()
		return self.visibility
	end

	def get_friendly_visibility_string()
		list = get_friendly_visibility_list()
		vis = get_visibility()
		list.each { |item|
			return item[:text] if item[:value] == vis
		}
		return ""	# this should never happen
	end

	def get_friendly_visibility_list()
		return [ { :value => 'everyone', :text => 'Everyone' }, { :value => 'members', :text => 'Members only' }, { :value => 'administrators', :text => 'Administrators only' }]
	end

	def get_visible_url
		#return "/clusters/#{self.id}" if self.visible_url == nil || self.visible_url.length == 0
		group = Group.find(self.group_id)
		group_url = group.get_visible_id()
		cluster_url = self.visible_url && self.visible_url.length > 0 ? self.visible_url : self.id
		return "/groups/#{group_url}/#{cluster_url}"
	end
	
	def get_truncated_name()
		return self.name if self.name.length < 70
		return self.name.slice(0..70) + "..."
	end
end
