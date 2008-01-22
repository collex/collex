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

describe "roles and permissions" do
  fixtures :exhibits, :exhibited_pages, :exhibited_items, :exhibited_sections, :users, :roles, :roles_users
  fixtures :licenses, :exhibit_section_types, :exhibit_page_types, :exhibit_types

  before(:each) do
    @owner = users(:exhibit_owner)
    @admin = users(:admin)
    @editor = users(:editor)
    @st = exhibit_section_types(:citation)
    @et = exhibit_types(:annotated_bibliography)
    @exhibit = exhibits(:dang)
  
  
    @exhibit.stub!(:index!)
  end
  it "admin user has admin role" do
    assert(@admin.admin_role?, "@admin should have admin_role?")
  end  

  it "editor user has editor role" do
    assert(@editor.editor_role?, "@editor should have editor_role?")
  end
  
  it "owner is true for owner" do
    assert(@exhibit.owner?(@owner), "owner? should have responded true.")
  end
  
  it "owner is true for owner id" do
    assert(@exhibit.owner?(@owner.id), "owner? should have responded true.")
  end
  
  it "owner is false for non owner" do
    user = User.new
    user.save
    assert( !@exhibit.owner?(user), "owner? should have responded false.")
  end
  
  it "owner is false for non owner id" do
    assert( !@exhibit.owner?(@owner.id + 1), "owner? should have responded false.")
  end
  
  # test permissions
  it "owner and admin can view exhibit" do
    assert @exhibit.viewable_by?(@owner)
    assert @exhibit.viewable_by?(@admin)
  end
  
  it "non owner can not view unshared exhibit" do
    assert(!@exhibit.viewable_by?(User.new), "Non-owner should not be able to view unshared exhibit.")
  end
  
  it "owner and admin can update exhibit" do
    assert(@exhibit.updatable_by?(@owner), "Owner should be able to update exhibit.")
    assert(@exhibit.updatable_by?(@admin), "Admin should be able to update exhibit.")
  end
  
  it "non owner can not update exhibit" do
    assert(!@exhibit.updatable_by?(User.new), "Non-owner should not be able to update exhibit.")
  end
  
  it "owner and admin can delete exhibit" do
    assert(@exhibit.deletable_by?(@owner), "Owner should be able to delete exhibit")
    assert(@exhibit.deletable_by?(@admin), "Admin should be able to delete exhibit")
  end
  
  it "non owner can not delete exhibit" do
    assert(!@exhibit.deletable_by?(User.new), "Non-owner should not be able to delete another's exhibit.")
  end
    
  it "anyone can view shared exhibit" do
    @exhibit.share!
    assert(@exhibit.viewable_by?(User.new), "Anyone should be able to view a shared exhibit.")
  end
  
  it "owner and admin can share exhibit" do
    assert(@exhibit.sharable_by?(@owner), "Owner should be able to share the exhibit.")
    assert(@exhibit.sharable_by?(@admin), "Admin should be able to share the exhibit.")
  end
  
  it "others cannot share exhibit" do
    assert(!@exhibit.sharable_by?(User.new), "Others should not be able to share the exhibit.")
    assert(!@exhibit.sharable_by?(Guest.new), "Guest should not be able to share the exhibit.")
  end

end

describe "sharing and publishing" do
  fixtures :exhibits, :exhibited_pages, :exhibited_items, :exhibited_sections, :users, :roles, :roles_users
  fixtures :licenses, :exhibit_section_types, :exhibit_page_types, :exhibit_types

  before(:each) do
    @owner = users(:exhibit_owner)
    @admin = users(:admin)
    @editor = users(:editor)
    @st = exhibit_section_types(:citation)
    @et = exhibit_types(:annotated_bibliography)
    @exhibit = exhibits(:dang)
    
    
    @exhibit.stub!(:index!)
    @exhibit.share!
  end
  
  it "publish! should call index!" do
    @exhibit.should_receive(:index!).once
    @exhibit.publish!
  end
  
  it "only an admin should be able to update a published exhibit" do
    @exhibit.publish! 
    @exhibit.updatable_by?(@owner).should == false
    @exhibit.updatable_by?(@editor).should == false
    @exhibit.updatable_by?(@admin).should == true
  end

  it "published exhibit should not be deletable" do
    @exhibit.publish!
    @exhibit.deletable_by?(@owner).should == false
    @exhibit.deletable_by?(@editor).should == false
    @exhibit.deletable_by?(@admin).should == false
  end
  
  it "a published exhibit should be viewable by anyone" do
    @exhibit.publish!
    @exhibit.viewable_by?(User.new).should == true
    @exhibit.viewable_by?(Guest.new).should == true
  end
  
  it "should be publishable only by admin" do
    @exhibit.publishable_by?(@owner).should == false
    @exhibit.publishable_by?(@admin).should == true
  end
  
  it "should not be sharable by anyone if published" do
    @exhibit.publish!
    @exhibit.sharable_by?(@owner).should == false
    @exhibit.sharable_by?(@admin).should == false
  end
  
  it "'publish!' should raise an error if exhibit is not shared" do
    @exhibit.shared = false
    lambda { @exhibit.publish! }.should raise_error(Exception)
    lambda { @exhibit.published = true }.should raise_error(Exception)
  end
  
  it "'publish' should not raise an error if shared" do
    lambda { @exhibit.publish! }.should_not raise_error(Exception)
    lambda { @exhibit.published = true }.should_not raise_error(Exception)
  end
  
  it "should not be unshareable once published" do
    @exhibit.publish!
    lambda { @exhibit.unshare! }.should raise_error(Exception)
    lambda { @exhibit.shared = false }.should raise_error(Exception)
  end
  
  it "should not be deletable once published" do
    @exhibit.deletable?.should == true
    @exhibit.publish!
    @exhibit.deletable?.should == false
  end
  
  it "should not be sharable once shared or published" do
    @exhibit.sharable?.should == false
    @exhibit.publish!
    @exhibit.sharable?.should == false
  end
  
  it "should be unsharable if shared but not published" do
    lambda { @exhibit.unshare! }.should_not raise_error
  end
end

describe "annotations()" do
  before(:each) do
    @exhibit = Exhibit.new(:annotation => "e1")
    @p1 = @exhibit.pages.build(:annotation => "p1")
    @p2 = @exhibit.pages.build(:annotation => "p2")
    @s1 = @p1.sections.build(:annotation => "s1")
    @s2 = @p2.sections.build(:annotation => "s2")
    @i1 = @s1.items.build(:annotation => "i1")
    @i2 = @s2.items.build(:annotation => "i2")
  end
  it "should return an array of all annotations in the Exhibit, down the tree to Items" do
    @exhibit.annotations.length.should == 7
    @exhibit.annotations.should include("e1")
    @exhibit.annotations.should include("p1")
    @exhibit.annotations.should include("p2")
    @exhibit.annotations.should include("s1")
    @exhibit.annotations.should include("s2")
    @exhibit.annotations.should include("i1")
    @exhibit.annotations.should include("i2")
  end
  it "should not include blanks" do
    @exhibit.annotation = nil
    @exhibit.pages.build(:annotation => "")
    @s2.items.build(:annotation => nil)
    @exhibit.annotations.length.should == 6
    @exhibit.annotations.should_not include("")
    @exhibit.annotations.should_not include(nil)
  end
end

describe "titles()" do
  before(:each) do
    @exhibit = Exhibit.new(:title => "e1")
    @p1 = @exhibit.pages.build(:title => "p1")
    @p2 = @exhibit.pages.build(:title => "p2")
    @s1 = @p1.sections.build(:title => "s1")
    @s2 = @p2.sections.build(:title => "s2")
  end
  it "should return an array of all titles in the Exhibit, down the tree to Items" do
    @exhibit.titles.length.should == 5
    @exhibit.titles.should include("e1")
    @exhibit.titles.should include("p1")
    @exhibit.titles.should include("p2")
    @exhibit.titles.should include("s1")
    @exhibit.titles.should include("s2")
  end
  it "should not include blanks" do
    @exhibit.title = nil
    @exhibit.pages.build(:title => "")
    @exhibit.titles.length.should == 4
    @exhibit.titles.should_not include("")
    @exhibit.titles.should_not include(nil)
  end
  
  describe "properties_to_index_with_values()" do
    before(:each) do
      res = Struct.new(:properties)
      prop = Struct.new(:name, :value)
      @exhibit = Exhibit.new
      @exhibit.stub!(:resources).and_return([res.new([prop.new('k1', 'v1'),
                                                      prop.new('k4', 'v1')]), 
                                             res.new([prop.new('k2', 'v1'), 
                                                      prop.new('k2', 'v2'), 
                                                      prop.new('k2', 'v2')])])
      @exhibit.stub!(:properties_to_index).and_return(['k1', 'k2'])
    end
    it "should return a Hash map with values in properties_to_index() as keys and the ExhibitedProperty values in Arrays as values" do
      @exhibit.properties_to_index_with_values.should == {'k1' => ['v1'], 'k2' => ['v1', 'v2']}
    end
  end
end

describe "folksonomy methods for the exhibit" do
  before(:each) do
    @exhibit = Exhibit.new
    @user_annotations = {
      "lisa_annotation" => "lisa's annotation",
      "bart_annotation" => "don't have a cow man",
      "milhouse_annotation" => "can I be your friend?"
    }
    @user_tags = {
      "lisa_tag" => ['malibu', 'stacy'],
      "bart_tag" => ['krusty', 'klown'],
      "milhouse_tag" => ['blue', 'hair', 'glasses']
    }
    
    # stub the solr_object method so we don't need a real connection
    @solr_object = {
      "username" => ['lisa', 'bart', 'milhouse'],
    }.merge(@user_annotations).merge(@user_tags)
    @exhibit.stub!(:solr_object).and_return(@solr_object)
  end
  it "'usernames' should just return a hash with key 'username' and the list of usernames from the solr_object's username list" do
    @exhibit.usernames.should == {'username' => @solr_object['username']}
  end
  it "'user_annotations' should return a Hash with <username>_annotation as the key to each annotation" do
    @exhibit.user_annotations.should == @user_annotations
  end
  it "'user_tags' should return a Hash with <username>_tag as the key to each Array of keywords" do
    @exhibit.user_tags.should == @user_tags
  end
end


