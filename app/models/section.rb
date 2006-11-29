class Section < ActiveRecord::Base
  belongs_to :section_type
  belongs_to :exhibit
  has_many :panels
end
