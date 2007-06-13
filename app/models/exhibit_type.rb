class ExhibitType < ActiveRecord::Base
  has_many :page_types, :class_name => "ExhibitPageType"
end
