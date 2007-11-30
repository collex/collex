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

require File.dirname(__FILE__) + '/../spec_helper'

describe ExhibitedSection do
  it "'genres' should return a unique, sorted list of the genres collected from the sections resources " do
    @es = ExhibitedSection.new
    r1 = mock("resource_1")
    r2 = mock("resource_2")
    r3 = mock("resource_3")
    r1.stub!(:genres).and_return(['one', 'two', 'three'])
    r2.stub!(:genres).and_return(['four', 'five', 'three'])
    r3.stub!(:genres).and_return(['six', 'five', 'one'])
    @es.should_receive(:exhibited_resources).and_return([r1, r2, r3])
    @es.genres.should == ['one', 'two', 'three', 'four', 'five', 'six'].sort
    
  end

end