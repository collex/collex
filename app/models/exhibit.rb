class Exhibit < ActiveRecord::Base
  belongs_to :user
  belongs_to :license
  belongs_to :exhibit_type
  has_many :sections
end
