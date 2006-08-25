class User < ActiveRecord::Base
  has_many :interpretations, :dependent => :destroy
end
