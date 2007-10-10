##########################################################################
# Copyright 2007 Applied Research in Patacriticism
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

require File.dirname(__FILE__) + '/../test_helper'

class ExhibitedSectionTest < Test::Unit::TestCase
  fixtures :exhibited_sections

  # some testing for the paginating_find plugin enhancements
  def test_find_all_returns_all_exhibited_sections
    assert(ExhibitedSection.find(:all).size > 1)
  end
  # this tests an enhancement to PaginatingFind: if Model has class reader page_size, this is automatically used
  def test_find_all_with_page_returns_page_size_number_of_items
    assert_equal(ExhibitedSection.page_size, ExhibitedSection.find(:all, :page).page_size)
  end

end
