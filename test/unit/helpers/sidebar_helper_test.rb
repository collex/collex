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

require File.dirname(__FILE__) + '/../../test_helper'

class SidebarHelperTest < HelperTestCase
  include SidebarHelper
  #fixtures :users, :articles
  
  def protect_against_forgery?
    false
  end
  
  def setup
    super
  end
  
  # title_for tests
  def test_title_for_returns_proper_title
    @object = {'title' => "The Title"}
    expected = "The Title"
    assert_equal(expected, title_for(@object))
  end
  
  def test_object_without_title_returns_untitled
    @object = {}
    expected = "<untitled>"
    assert_equal(expected, title_for(@object))
    
    @object['title'] = ""
    assert_equal(expected, title_for(@object))
  end

  # sb_link_to_remote tests
  def test_sb_link_to_remote_generates_label_from_value
    @type = "agent"
    @value = "David Ferris"
    expected = %Q{<a onclick="new Ajax.Updater('sidebar', '/sidebar/list/agent/David%20Ferris', {asynchronous:true, evalScripts:true}); return false;" href="#">David Ferris</a>}
    assert_dom_equal(expected, sb_link_to_remote(@type, @value))
  end
  
  def test_sb_link_to_remote_generates_label_from_label_argument
    @type = "agent"
    @value = "David Ferris"
    @label = "LOUD LABEL"
    expected = %Q{<a onclick="new Ajax.Updater('sidebar', '/sidebar/list/agent/David%20Ferris', {asynchronous:true, evalScripts:true}); return false;" href="#">LOUD LABEL</a>}
    assert_dom_equal(expected, sb_link_to_remote(@type, @value, @label))
  end
  
  def test_cloud_object_renders_properly
    expected = %(<div class="cloud_object">2 <span class="emph2">some_user</span> objects</div>)
    assert_equal(expected, cloud_object("2", "some_user"))
  end
  
end
