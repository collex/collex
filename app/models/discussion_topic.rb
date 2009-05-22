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

class DiscussionTopic < ActiveRecord::Base
  has_many :discussion_threads
  acts_as_list
  
  def self.get_all_with_date()
    topics = DiscussionTopic.find(:all)
    topics_and_date = []
    for topic in topics
      topics_and_date.insert(-1, { :date => topic.get_last_updated_date(), :topic_rec => topic })
    end
    return topics_and_date
  end
  
  def get_last_updated_date()
    threads = self.discussion_threads
    newest_date = nil
    for thread in threads
      comments = thread.discussion_comments
      last_comment_time = comments[comments.length-1].updated_at
      if newest_date == nil || newest_date < last_comment_time
        newest_date = last_comment_time
      end
    end
    return newest_date
  end
end
