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
	# This contains the functional differences between Collex and the specific implementation of it.
	# In this case, this is the NINES specific stuff
  def self.version	# Don't change the format of this call because collex.rake depends on it!
    return "1.6.2"
  end

	def self.yui_path()
		return '2.9.0'
	end

	def self.valid_genre_list()
		return [ "Architecture",
        "Artifacts", "Bibliography",
        "Collection", "Criticism", "Drama",
        "Education", "Ephemera", "Fiction",
        "History", "Leisure", "Letters",
        "Life Writing", "Manuscript", "Music",
        "Nonfiction", "Paratext", "Periodical",
        "Philosophy", "Photograph", "Poetry",
        "Religion", "Review", "Science",
        "Translation", "Travel",
        "Visual Art", "Citation",
        "Book History", "Family Life", "Folklore",
        "Humor", "Law", "Reference Works", "Sermon" ]
	end
end
