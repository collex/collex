class ImageFull < ActiveRecord::Base
  has_attachment :content_type => :image,
                 :storage => :file_system,
                 :path_prefix=>'public/uploads_full'

  validates_as_attachment
end
