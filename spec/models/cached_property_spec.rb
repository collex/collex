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

describe CachedProperty do
  before(:each) do
    @cached_property = CachedProperty.new
  end

  it "== should evaluate equality of name and value" do
    cp1 = CachedProperty.new(:name => "name 1", :value => "value 1")
    cp2 = CachedProperty.new(:name => "name 1", :value => "value 1")
    cp3 = CachedProperty.new(:name => "name 1", :value => "value 3")
    cp4 = CachedProperty.new(:name => "name 4", :value => "value 4")
    cp1.should == cp2
    cp1.should_not == cp3
    cp1.should_not == cp4
  end
  
  it "should strip 'role_' from name when 'agent_type' called" do
    cp = CachedProperty.new(:name => "role_AUT", :value => "Famous Person")
    cp.agent_type.should == "AUT"
  end
  
  it "== should be false if other is nil" do
    cp1 = CachedProperty.new(:name => "name 1", :value => "value 1")
    cp1.should_not == nil
  end
  
  it "== should evaluate equality of name and value with SolrProperty" do
    cp1 = CachedProperty.new(:name => "name 1", :value => "value 1")
    cp2 = SolrProperty.new(:name => "name 1", :value => "value 1")
    cp1.should == cp2
  end
end
