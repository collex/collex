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

class Branding
	# Here are some version numbers that we'd like to keep together.
  def self.version	# Don't change the format of this call because collex.rake depends on it!
    return "1.7.1"
  end

	def self.yui_path()
		# note: upgrading to 2.9.0 causes the dialogs to scroll the browser to the top.
		return '2.8.2'
	end
end
