class ExhibitedPage < ActiveRecord::Base
  has_many :exhibited_sections, :order => "position", :dependent => :destroy
  belongs_to :exhibit_page_type
  belongs_to :exhibit
  acts_as_list :scope => :exhibit
  
  def template
    self.exhibit_page_type.template
  end
  
end
