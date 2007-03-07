class Constraint < ActiveRecord::Base
  belongs_to :search
  
  def operator
    inverted ? '-' : ''
  end
end
