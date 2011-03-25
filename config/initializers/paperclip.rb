# Initialize Paperclip

config_file = File.join(Rails.root, "config", "site.yml")
if File.exists?(config_file)
	site_specific = YAML.load_file(config_file)
	IMAGE_MAGIC_PATH = site_specific['paperclip']['image_magic_path']

	Paperclip.options[:command_path] = IMAGE_MAGIC_PATH
	Paperclip.options[:swallow_stderr] = false

	#
	# TODO-PER: This is a monkey patch to get Paperclip working. It might not be needed in future versions.
	#
	if defined? ActionDispatch::Http::UploadedFile
	  ActionDispatch::Http::UploadedFile.send(:include, Paperclip::Upfile)
	end

else
	puts "***"
	puts "*** Failed to load site configuration. Did you create config/site.yml?"
	puts "***"
end
