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

describe CachedResource do
  before(:each) do
    @cr = mock_model(CachedResource)
  end

  it "'date_label_or_date' should return date_label if present, date otherwise" do
    @cr = CachedResource.new
    @cr.properties << CachedProperty.new(:name => "date", :value => "2007-01-01")
    @cr.date_label_or_date.should == "2007-01-01"
    @cr.properties << CachedProperty.new(:name => "date_label", :value => "January 1, 2007")
    @cr.date_label_or_date.should == "January 1, 2007"    
  end
  
  it "'resource' should return empty SolrResource if Solr returns null for the id" do
    er = CachedResource.new
    er.resource.class.should eql SolrResource
  end
  
  it "'after_create' should copy the SolrResource properties into CachedProperties" do
    @sr = SolrResource.new
    @sr.properties << SolrProperty.new(:name => "the name 1", :value => "the value 1")
    @sr.properties << SolrProperty.new(:name => "the name 2", :value => "the value 2")
    SolrResource.stub!(:find_by_uri).and_return(@sr)
    er = CachedResource.create(:url => "http://fake.url.com", :cached_section_id => 1)
    er.resource.should == @sr
    
    er.properties.size.should == 2
    er.properties.size.should == @sr.properties.size
    er.properties.each { |prop| @sr.properties.include?(prop) }
  end
end
