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

class AddCourseSyllabusData < ActiveRecord::Migration
  class ExhibitType < ActiveRecord::Base
    has_many :exhibit_page_types, :dependent => :destroy
  end
  class ExhibitPageType < ActiveRecord::Base
    has_many :exhibit_section_types, :dependent => :destroy
  end
  class ExhibitSectionType < ActiveRecord::Base ; end
  
  def self.up
    et = ExhibitType.new(:description => "Course Syllabus", :template => "course_syllabus", :title_message => "(Insert Course Name)", :annotation_message => "(Insert Course Description)")
    et.save
    et.exhibit_page_types.create(:name => "Course Syllabus Page Type", 
                                 :description => "Course Syllabus pages have one section per page.", 
                                 :min_sections => 1,
                                 :max_sections => 1,
                                 :title_message => "(Insert Date)",
                                 :annotation_message => "(Insert Date Notes)")
    et.exhibit_page_types.first.exhibit_section_types.create(:description => "Citation", 
                                                             :template => "citation", 
                                                             :name => "Citation",
                                                             :title_message => "(Insert Section Title)",
                                                             :annotation_message => "(Insert Section Description)")
  end

  def self.down
    begin
      et = ExhibitType.find_by_template("course_syllabus")
      et.destroy
    rescue
    end
  end
end
