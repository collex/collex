class Image < ActiveRecord::Base

  has_one :user
  
  has_attachment :content_type => :image, 
                 :storage => :file_system,
                 :path_prefix=>'public/uploads',
                 :max_size => 500.kilobytes,
                 :resize_to => '180x180',
                 :thumbnails => { :thumb => '60x60', :smaller => '35x35', :micro => '25x25' }

  validates_as_attachment
end