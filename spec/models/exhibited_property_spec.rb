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

require File.dirname(__FILE__) + '/../spec_helper'

describe ExhibitedProperty do
  before(:each) do
    @exhibited_property = ExhibitedProperty.new
  end

  it "== should evaluate equality of name and value" do
    ep1 = ExhibitedProperty.new(:name => "name 1", :value => "value 1")
    ep2 = ExhibitedProperty.new(:name => "name 1", :value => "value 1")
    ep3 = ExhibitedProperty.new(:name => "name 1", :value => "value 3")
    ep4 = ExhibitedProperty.new(:name => "name 4", :value => "value 4")
    ep1.should == ep2
    ep1.should_not == ep3
    ep1.should_not == ep4
  end
  
  it "== should be false if other is nil" do
    ep1 = ExhibitedProperty.new(:name => "name 1", :value => "value 1")
    ep1.should_not == nil
  end
  
  it "== should evaluate equality of name and value with SolrProperty" do
    ep1 = ExhibitedProperty.new(:name => "name 1", :value => "value 1")
    ep2 = SolrProperty.new(:name => "name 1", :value => "value 1")
    ep1.should == ep2
  end
end
