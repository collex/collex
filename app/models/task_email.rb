class TaskEmail < ActiveRecord::Base
	validates_presence_of :archive_name, :email
	validates_uniqueness_of :archive_name
end
