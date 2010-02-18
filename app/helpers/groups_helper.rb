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

module GroupsHelper
	def get_group_default_url(url)
    return "/images/#{SKIN}/glossy_swirly.jpg" if url == nil || url.length == 0
    return url
	end
	def get_group_image_url(group)
		return group.group_type == 'classroom' ? "/images/#{SKIN}/classroom_icon.sm.jpg" : get_group_default_url(get_url_for_internal_image(group.image, :thumb))
	end

	def get_cluster_image_url(group, cluster)
		return "/images/#{SKIN}/classroom_icon.sm.jpg" if group.group_type == 'classroom'
		image_class = cluster.image ? cluster : group
		return get_group_default_url(get_url_for_internal_image(image_class.image))
	end
end
