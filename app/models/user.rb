class User < ActiveRecord::Base
  has_many :interpretations, :dependent => :destroy
  has_many :exhibits
end
