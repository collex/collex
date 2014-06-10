class ImageFull < ActiveRecord::Base
#  has_attachment :content_type => :image,
#                 :storage => :file_system,
#                 :path_prefix=>'public/uploads_full'
#
#  validates_as_attachment
#  include Paperclip
  path = "photos_full/:id/:style/:basename.:extension"
  # to create a cropped image, use :thumb=> "100x100#".
  has_attached_file :photo,
	  :url  => path,
	  :path => ":rails_root/public/#{path}"
  validates_attachment_size :photo, :less_than => 1.megabytes,  :unless => Proc.new {|m| m[:photo].nil?}
  validates_attachment_content_type :photo, :content_type => ['image/jpeg', 'image/png', 'image/gif'], :unless => Proc.new {|m| m[:photo].nil?}

  def self.save_image(uploaded_file, target_active_record)
	  if uploaded_file && uploaded_file.original_filename.length > 0
		  user_error = "ERROR: The image you have uploaded is too large or of the wrong type.<br />The file name must end in .jpg, .png or .gif, and cannot exceed 1MB in size."
		  begin
			  img = ImageFull.new
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
				  target_active_record.image_full_id = img.id
				  target_active_record.save
			  end
			  return { :status => :saved, :id => img.id }
		  rescue Exception => msg
			  return { :status => :error, :log_error => "**** ERROR: Uploading picture: " + msg, :user_error => user_error }
		  end
	  end
	  return { :status => :no_image }
  end
end

