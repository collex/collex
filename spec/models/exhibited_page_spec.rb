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

describe ExhibitedPage do
  fixtures :exhibits, :exhibited_pages, :exhibit_page_types, :exhibited_sections
  before(:each) do
    @ie_1 = exhibited_pages(:illustrated_essay_1)
  end

  it "'sections()' should be an alias for 'exhibited_sections'" do
    @ie_1.exhibited_sections.should == (@ie_1.sections)
    @ie_1.exhibited_sections.create({:exhibit_section_type_id => 1, :title => "IE section"})
    @ie_1.exhibited_sections.should == (@ie_1.sections)
    
    @ie_1.sections.create({:exhibit_section_type_id => 1, :title => "Another IE section"})
    @ie_1.exhibited_sections.should == (@ie_1.sections)
  end
  
  it "'sections_full?' should return true if the page has max number of sections allowed" do
    page = ExhibitedPage.new
    exhibit_page_type = mock("exhibit_page_type", :null_object => true)
    exhibit_page_type.stub!(:max_sections).and_return(3)
    page.stub!(:exhibit_page_type).and_return(exhibit_page_type)
    page.sections.stub!(:count).and_return(3)
    page.sections_full?.should == true
  end
  
  it "'sections_full?' should return false if the page has less than max number of sections allowed" do
    page = ExhibitedPage.new
    exhibit_page_type = mock("exhibit_page_type", :null_object => true)
    exhibit_page_type.stub!(:max_sections).and_return(10)
    page.stub!(:exhibit_page_type).and_return(exhibit_page_type)
    page.sections.stub!(:count).and_return(9)
    page.sections_full?.should == false
  end
  
  it "'genres' should return a unique, sorted list of the genres collected from the page's sections " do
    @ep = ExhibitedPage.new
    s1 = mock("section_1")
    s2 = mock("section_2")
    s3 = mock("section_3")
    s1.stub!(:genres).and_return(['one', 'two', 'three'])
    s2.stub!(:genres).and_return(['four', 'five', 'three'])
    s3.stub!(:genres).and_return(['six', 'five', 'one'])
    @ep.should_receive(:exhibited_sections).and_return([s1, s2, s3])
    @ep.genres.should == ['one', 'two', 'three', 'four', 'five', 'six'].sort
  end
  
end
