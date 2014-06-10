##########################################################################
# Copyright 2009 Applied Research in Patacriticism and the University of Virginia
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##########################################################################

class Image < ActiveRecord::Base

  has_one :user
  has_one :featured_object
  #has_one :facet_category
  
#  has_attachment :content_type => :image,
#                 :storage => :file_system,
#                 :path_prefix=>'public/uploads',
#                 :resize_to => '300x300',
#                 :thumbnails => { :feature => '125x125', :thumb => '60x60', :smaller => '35x35', :micro => '25x25' }
#
#  validates_as_attachment
#  include Paperclip
  path = "photos_small/:id/:style/:basename.:extension"
  # to create a cropped image, use :thumb=> "100x100#".
  has_attached_file :photo, :styles => { :normal => '300x300', :feature => '125x125', :thumb => '60x60', :smaller => '35x35', :micro => '25x25' },
	  :url  => path,
	  :path => ":rails_root/public/#{path}"
	validates_attachment_size :photo, :less_than => 1.megabytes,  :unless => Proc.new {|m| m[:photo].nil?}
	validates_attachment_content_type :photo, :content_type => ['image/jpeg', 'image/png', 'image/gif'], :unless => Proc.new {|m| m[:photo].nil?}

	def self.save_image(uploaded_file, target_active_record)
		if uploaded_file && !uploaded_file.kind_of?(String) && uploaded_file.original_filename.length > 0
			user_error = "ERROR: The image you have uploaded is too large or of the wrong type.<br />The file name must end in .jpg, .png or .gif, and cannot exceed 1MB in size."
			begin
				img = Image.new
				img.photo = uploaded_file
				img.save
				if !img.errors.blank? && img.errors.size > 0
					log_error = ""
					img.errors.keys.each { |field|
						img.errors[field].each { |msg|
							log_error += msg  + "\n"
						}
					}
					return { :status => :error, :log_error => "**** ERROR: Uploading picture: " + log_error, :user_error => user_error }
				end
				if target_active_record
					target_active_record.image_id = img.id
					target_active_record.save
				end
				return { :status => :saved, :id => img.id }
			rescue Exception => msg
				return { :status => :error, :log_error => "**** ERROR: Uploading picture: " + msg.message, :user_error => user_error }
			end
		end
		return { :status => :no_image }
	end

end