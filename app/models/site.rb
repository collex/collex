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

#class Site < ActiveRecord::Base
#  # Returns a list of +String+s representing the available +thumbnail+ URLs of all sites
#  def self.thumbnails
#    find(:all, :select => "thumbnail").collect{|v| v.thumbnail unless v.thumbnail.blank?}.compact.uniq
#  end
#
#  # Returns a list of +String+s representing the available +thumbnail+ URLs for the site +code+s (+archive+ in the solr index)
#  def self.thumbnails_for_codes(codes = [])
#    find_all_by_code(codes, :select => "thumbnail").collect{|v| v.thumbnail unless v.thumbnail.blank?}.compact.uniq
#  end
#end
