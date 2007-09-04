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
                                 :title_message => "(Insert Page Title)",
                                 :annotation_message => "(Insert Page Notes)")
    et.exhibit_page_types.first.exhibit_section_types.create(:description => "Citation", 
                                                             :template => "citation", 
                                                             :name => "Citation",
                                                             :title_message => "(Insert Section Title)",
                                                             :annotation_message => "(Insert Section Description)")
  end

  def self.down
    et = ExhibitType.find_by_template("course_syllabus")
    et.destroy
  end
end
