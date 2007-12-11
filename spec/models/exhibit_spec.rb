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

describe Exhibit do
  fixtures :exhibits, :exhibited_pages, :exhibit_page_types, :exhibited_sections
  
  before(:each) do
    @exhibit = Exhibit.new
    @exhibit.title = "Exhibit Title"
    (@user = User.new).save
    @exhibit.user = @user
    
    (@et = ExhibitType.new).save
    @exhibit.exhibit_type = @et
    
    (@license = License.new).save
    @exhibit.license = @license
    
    @exhibit.save
  end

  it "should test authorization/roles for Exhibit" do
    
  end
  
  it "'indexed?' should return false if there is no uri" do
    @exhibit.indexed?.should == false
  end
  
  it "'indexed?' should return false if there is a uri but object is not in index" do
    @solr = mock("collex_engine")
    @solr.stub!(:indexed?).and_return(false)
    @exhibit.stub!(:solr).and_return(@solr)
    @exhibit.uri = "as1234ds345s34ft"
    @exhibit.indexed?.should == false
  end
  
  it "'indexed?' should return true if there is a uri and the object exists in index" do
    @solr = mock("collex_engine")
    @solr.stub!(:indexed?).and_return(true)
    @exhibit.stub!(:solr).and_return(@solr)
    @exhibit.uri = "as1234ds345s34ft"
    @exhibit.indexed?.should == true
  end
  
  it "'index!' should create a uri if none" do
    @solr = mock("collex_engine")
    @solr.stub!(:indexed?).and_return(false)
    @connection = mock("connection")
    @connection.stub!(:add)
    @connection.stub!(:commit)
    @solr.stub!(:connection).and_return(@connection)
    @exhibit.stub!(:solr).and_return(@solr)
    
    @exhibit.indexed?.should == false
    @exhibit.uri.should be_nil
    
    @exhibit.index!
    @exhibit.uri.should_not be_nil
  end
  
  it "'index!' should add the exhibit to the Solr index with the uri as the object id" do
    @solr = mock("collex_engine")
    @exhibit.stub!(:solr).and_return(@solr)
    @connection = mock("connection")
    @connection.stub!(:add)
    @connection.stub!(:commit)
    @solr.stub!(:connection).and_return(@connection)
    
    @exhibit.indexed?.should == false
    @exhibit.uri.should be_nil
    
    @exhibit.index!
    @exhibit.uri.should_not be_nil
    @solr.should_receive(:indexed?).and_return(true)
    @exhibit.indexed?.should be true
  end
  
  it "should index 'uri'" do
  end
  
  it "should index 'url'" do
  end
  
  it "should index 'archive'" do
  end
  
  it "should index 'author'" do
  end
  
  it "should index 'exhibit_type'" do
  end
  
  it "should index 'published'" do
  end
  
  it "should index 'license'" do
  end
  
  it "should index 'genre' as a list" do
  end
  
end
