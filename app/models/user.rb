class User < ActiveRecord::Base
  has_many :interpretations, :dependent => :destroy
  has_many :exhibits
  has_and_belongs_to_many :roles
end
