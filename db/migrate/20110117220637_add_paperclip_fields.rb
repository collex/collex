class AddPaperclipFields < ActiveRecord::Migration
  def self.up
	  add_column :images, :photo_file_name, :string
	  add_column :images, :photo_content_type, :string
	  add_column :images, :photo_file_size, :string
	  add_column :images, :photo_updated_at, :string
	  add_column :image_fulls, :photo_file_name, :string
	  add_column :image_fulls, :photo_content_type, :string
	  add_column :image_fulls, :photo_file_size, :string
	  add_column :image_fulls, :photo_updated_at, :string
  end

  def self.down
	  remove_column :images, :photo_file_name, :string
	  remove_column :images, :photo_content_type, :string
	  remove_column :images, :photo_file_size, :string
	  remove_column :images, :photo_updated_at, :string
	  remove_column :image_fulls, :photo_file_name, :string
	  remove_column :image_fulls, :photo_content_type, :string
	  remove_column :image_fulls, :photo_file_size, :string
	  remove_column :image_fulls, :photo_updated_at, :string
  end
end
