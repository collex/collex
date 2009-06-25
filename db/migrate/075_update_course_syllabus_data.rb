##########################################################################
# Copyright 2008 Applied Research in Patacriticism and the University of Virginia
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

class UpdateCourseSyllabusData < ActiveRecord::Migration
  class ExhibitType < ActiveRecord::Base
    has_many :exhibit_page_types, :dependent => :destroy
    has_many :exhibits
  end
  class ExhibitPageType < ActiveRecord::Base
    has_many :exhibit_section_types, :dependent => :destroy
    has_many :exhibited_pages
  end
  class ExhibitSectionType < ActiveRecord::Base ; end
  
  class Exhibit < ActiveRecord::Base
    belongs_to :exhibit_type
    has_many :exhibited_pages, :dependent => :destroy
  end
  class ExhibtedPage < ActiveRecord::Base
    belongs_to :exhibit_page_type
    has_many :exhibited_sections, :dependent => :destroy
  end
  class ExhibitedSection < ActiveRecord::Base
    belongs_to :exhibited_page
  end
  
  def self.up
    et = ExhibitType.find_by_template("course_syllabus")
    et.exhibit_page_types.first.update_attributes(
      :description => "Course Syllabus pages have 100 sections per page.", 
      :max_sections => 100,
      :title_message => "(Insert Page Title)",
      :annotation_message => "(Insert Page Notes)")
    et.exhibit_page_types.first.exhibit_section_types.first.update_attributes(
      :title_message => "(Insert Date)",
      :annotation_message => "(Insert Date Notes)")
      
    # now let's move the current date and its annotation from the page to the section
    et.exhibits.each do |exhibit|
      exhibit.exhibited_pages.each do |page|
        page.exhibited_sections.first.title = page.title
        page.exhibited_sections.first.annotation = page.annotation
        page.exhibited_sections.first.save
        page.title = nil
        page.annotation = nil
        page.save
      end
    end
  end

  # oldTODO write a down script for putting exhibits
  def self.down
    et = ExhibitType.find_by_template("course_syllabus")
    et.exhibit_page_types.first.update_attributes(
      :description => "Course Syllabus pages have one section per page.", 
      :max_sections => 1,
      :title_message => "(Insert Date)",
      :annotation_message => "(Insert Date Notes)")
    et.exhibit_page_types.first.exhibit_section_types.first.update_attributes(
      :title_message => "(Insert Section Title)",
      :annotation_message => "(Insert Section Description)")
      
    exhibit_page_type_id = ExhibitPageType.find(:first, :conditions => "name like 'Course Syllabus%'").id
    et.exhibits.each do |exhibit|
      old_pages = exhibit.exhibited_pages
      old_page_ids = exhibit.exhibited_page_ids

      sections = old_pages.collect{|page| page.exhibited_sections }.flatten
      sections.each do |section|
        page = ExhibitedPage.new(:title => section.title, :annotation => section.annotation, :exhibit_page_type_id => exhibit_page_type_id)
        exhibit.exhibited_pages << page
        page.exhibited_sections << section
        page.save
      end
      exhibit.exhibited_pages.delete(ExhibitedPage.find(old_page_ids))
      # fix the page ordering
      exhibit.exhibited_pages.each_with_index do |page, index|
        page.position = index + 1
        page.save
      end
    end
  end
end
