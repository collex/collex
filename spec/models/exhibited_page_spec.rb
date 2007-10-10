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
end
