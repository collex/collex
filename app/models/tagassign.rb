class Tagassign < ActiveRecord::Base
  belongs_to :tag
  belongs_to :collected_item
end
