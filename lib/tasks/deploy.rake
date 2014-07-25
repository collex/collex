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

desc "Do all tasks that routinely need to be done when anything changes in the source repository -- the style of update is in site.yml"
task :deploy => [ 'deploy:update' ] do
end

def finish_line(start_time)
	duration = Time.now-start_time
	if duration >= 60
		str = "Finished in #{"%.2f" % (duration/60)} minutes."
	else
		str = "Finished in #{"%.2f" % duration} seconds."
	end
	#CollexEngine.report_line_if(str)
	puts str
end

namespace :deploy do

#	def stop_daemons
#		puts "Stopping all daemons..."
#		puts `script/delayed_job stop`
##		puts `lib/daemons/index_user_content_ctl stop`
#		puts `lib/daemons/mailer_ctl stop`
#		puts `lib/daemons/session_cleaner_ctl stop`
#		sleep(8)
#	end
#
#	def start_daemons
#		puts "Starting all daemons..."
#		puts `script/delayed_job start`
#		puts `lib/daemons/mailer_ctl start`
#		puts `lib/daemons/session_cleaner_ctl start`
#	end

	#def tag_current_version
	#	# This uses the current version number as the name of the tag. If that tag already exists, a letter is appended to it so that it is unique.
	#	# version = Branding.version() -- may report one version behind if we just updated.
	#	# Read the version directly because we might have just done an "svn up" and so we are actually running one version behind.
	#	version = ""
	#	File.open("#{Rails.root}/app/models/branding.rb", "r") do |file|
	#		wants_this = false
	#		while line = file.gets
	#			if wants_this && version.length == 0
	#				arr = line.split("\"")
	#				version = arr[1]
	#			elsif line.index("self.version") != nil
	#				wants_this = true
	#			end
	#		end
	#	end
	#
	#	if version.length == 0
	#		puts "Can't tag version because the format of branding.rb"
	#	else
	#		output = `svn info #{SVN_COLLEX}/tags/#{version}`
	#		if output.index("Path: #{version}") == 0	# the tag already exists, so bump up the tag version
	#			finished = false
	#			letter = 'a'
	#			while !finished
	#				output = `svn info #{SVN_COLLEX}/tags/#{version}#{letter}`
	#				finished = output.index("Path: #{version}#{letter}") != 0
	#				letter[0] = letter[0]+1 if !finished
	#			end
	#			version += letter
	#		end
	#		puts "Tagging version #{version}..."
	#		system("svn copy -rHEAD -m tag #{SVN_COLLEX}/trunk/web #{SVN_COLLEX}/tags/#{version}")
	#	end
	#end

	#desc "Tag the current collex version; make a backup of the production site"
	#task :tag => :environment do
	#	version = Branding.version()
	#	puts "You will be asked for your NINES mysql password."
	#	`mysqldump nines_production -u nines -p > ~/backups/backup_nines_#{version}.sql`
	#	puts "You will be asked for your 18thConnect mysql password."
	#	`mysqldump 18th_production -u nines -p > ~/backups/backup_18th_#{version}.sql`
	#	tag_current_version()
	#end

	#def deploy_on_production
	#	puts "Deploy latest version on production..."
	#	update_edge()
	#end
	#
	#def basic_update
	#	stop_daemons()
	#	puts `git checkout db/schema.rb`
	#	puts `git pull`
	#	run_bundler()
	#	copy_dir( "#{Rails.root}/public/static/#{SKIN}", "#{Rails.root}/public" )
	#	Rake::Task['db:migrate'].invoke
	#end
	#
	#def update_edge
	#	puts "Update site from repository..."
	#	basic_update()
	#`mkdir -p #{Rails.root}/tmp`
	#`touch #{Rails.root}/tmp/restart.txt`
	#	#`sudo /sbin/service httpd restart`
	#	#puts "\e[0;31mRun this to restart passenger:"
	#	#puts "~/scripts/restart_passenger.sh #{Setup.site_name()} \e[m"
	#	start_daemons()
	#end
	#
	#def update_development
	#	puts "Update site from repository..."
	#	basic_update()
	#	`mongrel_rails restart`
	#	start_daemons()
	#end
	#
	#desc "Do all tasks that routinely need to be done when anything changes in the source repository -- the style of update is in site.yml"
	#task :update => :environment do
	#	puts "Update type: #{UPDATE_TASK}"
	#	if UPDATE_TASK == 'production'
	#		deploy_on_production()
	#	elsif UPDATE_TASK == 'development'
	#		update_development()
	#	elsif UPDATE_TASK == 'edge'
	#		update_edge()
	#	else
	#		puts "Unknown updating type. Compare the value in config/site.yml and the list in the deploy:update rake task (file: deploy.rake)."
	#	end
	#end
	#
	#def run_bundler()
	#	gemfile = "#{Rails.root}/Gemfile"
	#	lock = "#{Rails.root}/Gemfile.lock"
	#	if is_out_of_date(gemfile, lock)
	#		puts "Updating gems..."
	#		puts `bundle update`
	#		`touch #{lock}`	# If there were no changes, the file isn't changed, so it will appear out of date every time this is run.
	#	end
	#end
	#
	#def is_out_of_date(src, dst)
	#	src_time = File.stat(src).mtime
	#	begin
	#		dst_time = File.stat(dst).mtime
	#	rescue
	#		# It's ok if the file doesn't exist; that means that we should definitely recreate it.
	#		return true
	#	end
	#	return src_time > dst_time
	#end
	#
	##
	## All tasks below here are not normally called separately, but can be if needed. They are called as part of the
	## tasks defined above.
	##
	#
	#def safe_mkdir(folder)
	#	begin
	#    Dir.mkdir(folder)
	#	rescue
	#		# It's ok to fail: it probably means the folder already exists.
	#	end
	#end
	
#  def copy_dir( start_dir, dest_dir )
#     puts "Copying the contents of #{start_dir} to #{dest_dir}..."
#     Dir.new(start_dir).each { |file|
#       unless file =~ /\A\./
##         start_file = "#{start_dir}/#{file}"
##         dest_file = "#{dest_dir}/#{file}"
#         `cp "#{start_dir}/#{file}" "#{dest_dir}/#{file}"`
#       end
#     }
#  end
#
#	desc "Compress the css for the about pages"
#	task :compress_about_css => :environment do
#		compress_file('stylesheets', '.css', "")
#		compress_file("stylesheets/#{SKIN}", '.css', "#{SKIN}__")
#		concatenate_css(:about)
#	end

  #def compress_css_js()
	#	# The purpose of this is to roll all our css and js files into one minimized file so that load time on the server is as short as
	#	# possible. Using this method allows different pages to have different sets of includes, and allows the developer to create
	#	# as many small css and js files as they want. See get_include_file_list.rb for details.
	#	compress_file('javascripts', '.js', "")
	#	compress_file("javascripts/typewright", '.js', "typewright__")
	#	compress_file('stylesheets', '.css', "")
	#	compress_file("stylesheets/#{SKIN}", '.css', "#{SKIN}__")
	#	compress_file("stylesheets/typewright", '.css', "typewright__")
  #
	#	concatenate_js(:typewright_edit)
	#	concatenate_css(:typewright_edit)
	#	concatenate_js(:typewright)
	#	concatenate_css(:typewright)
	#	concatenate_js(:my_collex)
	#	concatenate_css(:my_collex)
	#	concatenate_js(:search)
	#	concatenate_css(:search)
	#	concatenate_js(:tag)
	#	concatenate_css(:tag)
	#	concatenate_js(:discuss)
	#	concatenate_css(:discuss)
	#	concatenate_js(:home)
	#	concatenate_css(:home)
	#	concatenate_js(:exhibits)
	#	concatenate_css(:exhibits)
	#	concatenate_js(:shared)
	#	concatenate_css(:shared)
	#	concatenate_js(:admin)
	#	concatenate_css(:admin)
	#	concatenate_js(:about)
	#	concatenate_css(:about)
	#	concatenate_js(:news)
	#	concatenate_css(:news)
	#	concatenate_js(:view_exhibit)
	#	concatenate_css(:view_exhibit)
	#	concatenate_js(:print_exhibit)
	#	concatenate_css(:print_exhibit)
	#end

	#desc "Compress all css and js files"
	#task :compress_css_js => :environment do
	#	compress_css_js()
	#  end
	#
	#def time_format(tim)
	#	return tim.getlocal().strftime("%b %d, %Y %I:%M%p")
	#end
	#
	#def compress_file(folder, ext, prefix)
	#	Dir.foreach("#{Rails.root}/public/#{folder}") { |f|
	#		if f.index(ext) == f.length - ext.length
	#			fname = f.slice(0, f.length - ext.length)
	#			if fname.index('-min') != fname.length - 4
	#				src_path = "#{Rails.root}/public/#{folder}/#{f}"
	#				dst_path = "#{Rails.root}/tmp/#{prefix}#{fname}-min#{ext}"
	#				src_time = File.stat(src_path).mtime
	#				begin
	#					dst_time = File.stat(dst_path).mtime
	#				rescue
	#					# It's ok if the file doesn't exist; that means that we should definitely recreate it.
	#					dst_time = 10.years.ago
	#				end
	#				if src_time > dst_time
	#					puts "Compressing #{f}..."
	#					system("java -jar #{Rails.root}/lib/tasks/yuicompressor-2.4.2.jar --line-break 7000 -o #{dst_path} #{src_path}")
	#				#else
	#					#puts "Skipping #{f}. Source time=#{time_format(src_time)}; Dest time=#{time_format(dst_time)}"
	#				end
	#			end
	#		end
	#	}
	#end

	#def concatenate_js(page)
	#	list_proto = []
	#	fnames = GetIncludeFileList.get_js(page)
	#	fnames[:prototype].each { |f|
	#		list_proto.push("#{Rails.root}/tmp/#{f}-min.js")
	#	}
	#
	#	list = []
	#	fnames[:local].each { |f|
	#		f =
	#		list.push("#{Rails.root}/tmp/#{f.gsub('/','__')}-min.js")
	#	}
	#
	#	dest ="javascripts/#{page.to_s()}-min.js"
	#	puts "Creating #{dest}..." # [\n\t#{list.join("\n\t")}]"
	#	system("cat #{list_proto.join(' ')} > #{Rails.root}/public/javascripts/prototype-min.js")
	#	system("cat #{list.join(' ')} > #{Rails.root}/public/#{dest}")
	#end
	#
	#def concatenate_css(page)
	#	list = []
	#	fnames = GetIncludeFileList.get_css(page)
	#	fnames[:local].each { |f|
	#		list.push("#{Rails.root}/tmp/#{f.gsub('/','__')}-min.css")
	#	}
	#	dest ="stylesheets/#{page.to_s()}-min.css"
	#	puts "Creating #{dest}..." # [\n\t#{list.join("\n\t")}]"
	#	list = list.join(' ')
	#	system("cat #{list} > #{Rails.root}/public/#{dest}")
	#end

#	desc "Automatically put users in a group"
#	task :join_users_to_group => :environment do
#		group_name = "ENGL 227"
#		group = Group.find_by_name(group_name)
#		if group == nil
#			puts "Can't find the group: #{group_name}"
#		else
#
#			exhibit_names = [
#				"Broxterman ENGL 227 Project",
#				"Langwell ENGL 227 Project",
#				"Rafferty ENGL227 Project",
#				"Slaughter ENGL 227 PROJECT",
#				"Stockton ENGL 227 Project",
#				"Culp ENGL 227 Project",
#				"Ince ENGL 227 Project",
#				"Waggoner ENGL 227 Project",
#				"Wolfshohl ENGL 227 Project",
#				"Carney ENGL 227 Project- The Hypocrisy of Christianity in Slavery",
#				"Sanders ENGL 227 Project",
#				"Brock ENGL 227 Project",
#				"Tarver ENGL 227 Project",
#				"Felix ENGL 227 Project",
#				"Valenta ENGL 227 Project",
#				"Wise, ENGL 227 Project",
#				"Thornton ENGL 227 Project",
#				"Jones English 227",
#				"Martensson english 227 Project",
#				"Cardenas ENGL 227",
#				"O'Connor ENGL 227",
#				"Herron English 227",
#				"AStewart engl227",
#				"Brown ENGL 227",
#				"Horn English 227",
#				"skrla english 227",
#				"Glaesmann, Clint English 227",
#				"Gerlach English 227",
#				"Godsey English 227",
#				"Rogers ENGL 227",
#				"Mitchell english 227",
#				"Venegas english 227",
#				"Lisle english 227",
#				"McClure ENGL 227",
#				"DeLeon English 227",
#				"Swanson English 227",
#				"weber english 227",
#				"Wells English 227",
#				"Orth Engl 227",
#				"Luza English 227",
#				"Willis ENG 227 Project",
#				"Potts Engl 227 Project",
#				"Baker English 227 Project",
#				"Davenport - Development and Understanding of the Native American Through Early American Literature",
#				"A Woman's Place By Ashley Arevalo ENGL 227",
#				"Welsh ENGL 227",
#				"marroquin ENGL 227 Project",
#				"Pearson English 227",
#				"Tollett English 227",
#				"Turner English 227",
#				"Pratt ENGL 227",
#				"Coryanne ENGL 227",
#				"Violence in Slavery",
#				"Stephenson English 227 Project",
#				"ENGL 227-Cooper",
#				"Spotts ENGL 227",
#				"Engl 227 project",
#				"Rekoff ENGL 227",
#				"Allen Class Project ENGL 227",
#				"American Independence ENGL 227",
#				"Brown ENGL 227",
#				"Ridley ENGL 227 Project",
#				"Buehler Eng 227",
#				"Earhart, Collex Project",
#				"Garrett ENGL 227 Project",
#				"Stuberfield, Class Project ENG 227",
#				"Domains and Domesticity - Class Project ENG 227",
#				"Brady Wright ENGL 227 project",
#				"jthompson227F09",
#				"ABell ENGL 227F09",
#				"M Torres 227F09",
#				"tayer 227F09",
#				"rbounds 227f09",
#				"V Goussen 227F09",
#				"astephens227F09",
#				"mlaman_227F09",
#				"tmoore227F09",
#				"MKasper227F09",
#				"Jroznos227F09",
#				"Koontz ENGL 227 Project",
#				"jreardon227F09",
#				"ABuitron227F09",
#				"SFraleigh227F09",
#				"MAdams227F09",
#				"pgarrett227F09",
#				"B. Holder 227F09",
#				"jhuff227F09",
#				"bfulmer227F09",
#				"APatton227F09",
#				"Early American Magazines AElder 227F09",
#				"EHuey ENGL 227 Project F09",
#				"ASwanberg227F09",
#				"MWalston227F09",
#				"MFelts ENGL227F09",
#				"MBrewster 227 F09",
#				"Risher ENGL 227 Project",
#				"btnguyen227F09",
#				"TSepe-22F09",
#				"K.McClainENG227",
#				"kpurgatorio227F09",
#				"BContreras 227F09"
#			]
#
#			exhibit_names.each{ |name|
#				exhibit = Exhibit.find_by_title(name)
#				if exhibit == nil
#					puts "Can't find the exhibit: #{name}"
#				else
#					user_id = exhibit.user_id
#					GroupsUser.auto_join(group.id, user_id)
#					exhibit.group_id = group.id
#					exhibit.save
#				end
#			}
#		end
#	end

#	def convert_user_field(field)
#		if "#{field}" == "NULL"
#			return nil
#		end
#		return "#{field}"
#	end
#
#	desc "Import users (file: filename)"
#	task :import_users => :environment do
#		contents = ""
#		File.open(Rails.root + ENV['file'], "r") { |f|
#			contents = f.read
#		}
#		lines = contents.split("\n")
#		lines.each {|line|
#			result = line.scan(/'()'|'(.*?[^\\])'|(NULL)/)
#			user = User.find_by_username(result[0])
#			if user == nil
#				puts "create user: #{result[0]}"
#				user = User.create(:username => convert_user_field(result[0]), :password_hash => convert_user_field(result[1]), :fullname => convert_user_field(result[2]), :email => convert_user_field(result[3]), :institution => convert_user_field(result[4]), :link => convert_user_field(result[5]), :about_me => convert_user_field(result[6]))
#			end
##			result.each_with_index { |r, x|
##				if r
##					puts "#{x}: #{r}"
##				end
##			}
##			puts "-----"
#		}
#
#	end


	#desc "Fix character set from CP1252 to utf-8"
	#task :fix_char_set => :environment do
	#	debug = false
	#	CharSetAlter.fix_cp1252(CachedProperty, :value, debug)
	#	CharSetAlter.fix_cp1252(Cluster, :name, debug)
	#	CharSetAlter.fix_cp1252(Cluster, :description, debug)
	#	CharSetAlter.fix_cp1252(CollectedItem, :annotation, debug)
	#	CharSetAlter.fix_cp1252(Constraint, :value, debug)
	#	CharSetAlter.fix_cp1252(DiscussionComment, :comment, debug)
	#	CharSetAlter.fix_cp1252(DiscussionThread, :title, debug)
	#	CharSetAlter.fix_cp1252(DiscussionTopic, :description, debug)
	#	CharSetAlter.fix_cp1252(ExhibitElement, :element_text, debug)
	#	CharSetAlter.fix_cp1252(ExhibitElement, :element_text2, debug)
	#	CharSetAlter.fix_cp1252(ExhibitFootnote, :footnote, debug)
	#	CharSetAlter.fix_cp1252(ExhibitIllustration, :alt_text, debug)
	#	CharSetAlter.fix_cp1252(ExhibitIllustration, :illustration_text, debug)
	#	CharSetAlter.fix_cp1252(ExhibitIllustration, :caption1, debug)
	#	CharSetAlter.fix_cp1252(ExhibitIllustration, :caption2, debug)
	#	CharSetAlter.fix_cp1252(Exhibit, :title, debug)
	#	#CharSetAlter.fix_cp1252(FacetCategory, :carousel_description, debug)
	#	CharSetAlter.fix_cp1252(FeaturedObject, :title, debug)
	#	CharSetAlter.fix_cp1252(FeaturedObject, :saved_search_name, debug)
	#	CharSetAlter.fix_cp1252(Group, :name, debug)
	#	CharSetAlter.fix_cp1252(Group, :description, debug)
	#	CharSetAlter.fix_cp1252(Group, :university, debug)
	#	CharSetAlter.fix_cp1252(Group, :course_name, debug)
	#	CharSetAlter.fix_cp1252(Group, :course_mnemonic, debug)
	#	CharSetAlter.fix_cp1252(ObjectActivity, :tagname, debug)
	#	CharSetAlter.fix_cp1252(Search, :name, debug)
	#	#CharSetAlter.fix_cp1252(Site, :description, debug)
	#	CharSetAlter.fix_cp1252(Tag, :name, debug)
	#	CharSetAlter.fix_cp1252(User, :username, debug)
	#	CharSetAlter.fix_cp1252(User, :fullname, debug)
	#	CharSetAlter.fix_cp1252(User, :institution, debug)
	#	CharSetAlter.fix_cp1252(User, :about_me, debug)
	#end
#	desc "Fix character set from CP1252 to utf-8"
#	task :fix_char_set => :environment do
#		# This was for a one time fix of the database when the character set was set to latin1 instead of utf8.
#		# It may be useful in the future if that happens again.
#		# downcase_tag changes all tags to just be lower case. This is also a one time fix to the database.
#		# If you set debug=true, you will get the status of the DB with changing anything.
#
#		#CharSetAlter.downcase_tag()
#		debug = false
#		CharSetAlter.cp1252_to_utf8(ExhibitElement, :element_text, debug)
#		CharSetAlter.cp1252_to_utf8(ExhibitElement, :element_text2, debug)
#		CharSetAlter.cp1252_to_utf8(ExhibitFootnote, :footnote, debug)
#		CharSetAlter.cp1252_to_utf8(ExhibitIllustration, :illustration_text, debug)
#		CharSetAlter.cp1252_to_utf8(ExhibitIllustration, :caption1, debug)
#		CharSetAlter.cp1252_to_utf8(ExhibitIllustration, :caption2, debug)
#		CharSetAlter.cp1252_to_utf8(CachedProperty, :value, debug)
#		CharSetAlter.cp1252_to_utf8(CollectedItem, :annotation, debug)
#		CharSetAlter.cp1252_to_utf8(DiscussionComment, :comment, debug)
#		CharSetAlter.cp1252_to_utf8(DiscussionThread, :title, debug)
#		CharSetAlter.cp1252_to_utf8(DiscussionTopic, :description, debug)
#		CharSetAlter.cp1252_to_utf8(Search, :name, debug)
#		CharSetAlter.cp1252_to_utf8(FacetCategory, :carousel_description, debug)
#		CharSetAlter.cp1252_to_utf8(Tag, :name, debug)
#		CharSetAlter.cp1252_to_utf8(User, :username, debug)
#		CharSetAlter.cp1252_to_utf8(User, :fullname, debug)
#		CharSetAlter.cp1252_to_utf8(User, :about_me, debug)
#	end

	desc "After running the migration to add paperclip fields, run this to convert the data and copy the files"
	task :migrate_attachment_fu_to_paperclip => :environment do
		# attachment_fu fields:
		# parent_id
		# content_type
		# filename
		# thumbnail
		# size
		# width
		# height
		# paperclip fields:
		# photo_file_name
		# photo_content_type
		# photo_file_size
		# photo_updated_at
		# ---------------------
		# attachment_fu file structure:
		#		uploads
		#			0000
		#				image_id (four digit)
		# paperclip file structure:
		#	photos_small
		#		image_id
		#			original
		#				file
		#			thumb
		#				file
		# ---------------------
		# To convert, read all rows where parent_id is NULL.
		# copy the attributes: content_type=photo_content_type, filename=photo_file_name; size=photo_file_size; updated_at=photo_updated_at
		# copy the files: uploads/0000/#{image_id}/#{filename} => photos_small/#{image_id}/original/#{filename}
		# copy the files: uploads/0000/#{image_id}/#{filename}_micro => photos_small/#{image_id}/micro/#{filename}
		# copy the files: uploads/0000/#{image_id}/#{filename}_smaller => photos_small/#{image_id}/smaller/#{filename}
		# copy the files: uploads/0000/#{image_id}/#{filename}_thumb => photos_small/#{image_id}/thumb/#{filename}
		# copy the files: uploads/0000/#{image_id}/#{filename}_feature => photos_small/#{image_id}/feature/#{filename}
		#
		# For the full size images:
		# copy the files: upload_full/0000/#{image_id}/#{filename} => photos_full/#{image_id}/original/#{filename}
		safe_mkdir("#{Rails.root}/public/photos_small")
		recs = Image.where({parent_id: nil})
		recs.each {|rec|
			rec.photo_file_name = rec.filename
			rec.photo_content_type = rec.content_type
			rec.photo_file_size = rec.size
			rec.photo_updated_at = rec.updated_at
			rec.save!
			safe_mkdir("#{Rails.root}/public/photos_small/#{rec.id}")
			safe_mkdir("#{Rails.root}/public/photos_small/#{rec.id}/original")
			safe_mkdir("#{Rails.root}/public/photos_small/#{rec.id}/thumb")
			safe_mkdir("#{Rails.root}/public/photos_small/#{rec.id}/feature")
			safe_mkdir("#{Rails.root}/public/photos_small/#{rec.id}/smaller")
			safe_mkdir("#{Rails.root}/public/photos_small/#{rec.id}/micro")
			arr = rec.filename.split('.')
			ext = arr.pop()
			fname = arr.join('.')
			id = "%04d" % rec.id
			from_folder = "#{Rails.root}/public/uploads/0000/#{id}"
			`cp #{from_folder}/#{fname}.#{ext} #{Rails.root}/public/photos_small/#{rec.id}/original/#{fname}.#{ext}`
			`cp #{from_folder}/#{fname}_thumb.#{ext} #{Rails.root}/public/photos_small/#{rec.id}/thumb/#{fname}.#{ext}`
			`cp #{from_folder}/#{fname}_feature.#{ext} #{Rails.root}/public/photos_small/#{rec.id}/feature/#{fname}.#{ext}`
			`cp #{from_folder}/#{fname}_smaller.#{ext} #{Rails.root}/public/photos_small/#{rec.id}/smaller/#{fname}.#{ext}`
			`cp #{from_folder}/#{fname}_micro.#{ext} #{Rails.root}/public/photos_small/#{rec.id}/micro/#{fname}.#{ext}`
		}

		safe_mkdir("#{Rails.root}/public/photos_full")
		recs = ImageFull.where({parent_id: nil})
		recs.each {|rec|
			rec.photo_file_name = rec.filename
			rec.photo_content_type = rec.content_type
			rec.photo_file_size = rec.size
			rec.photo_updated_at = rec.updated_at
			rec.save!
			safe_mkdir("#{Rails.root}/public/photos_full/#{rec.id}")
			safe_mkdir("#{Rails.root}/public/photos_full/#{rec.id}/original")
			arr = rec.filename.split('.')
			ext = arr.pop()
			fname = arr.join('.')
			id = "%04d" % rec.id
			from_folder = "#{Rails.root}/public/uploads_full/0000/#{id}"
			`cp #{from_folder}/#{fname}.#{ext} #{Rails.root}/public/photos_full/#{rec.id}/original/#{fname}.#{ext}`
		}

		# After running this, change all public_filename to photo.url
	end

	desc "After converting and testing Paperclip, run this to remove the traces of attachment_fu"
	task :migrate_attachment_fu_to_paperclip => :environment do
		# remove all Image nad ImageFull recs where parent_id is not nil
  end

  desc "add setup values for enabling tabs"
  task :add_setup_values_for_tab_enabling => :environment do
    Setup.create({ key: "enable_community_tab", value: "true" })
    Setup.create({ key: "enable_search_tab", value: "true" })
    Setup.create({ key: "enable_publications_tab", value: "true" })
    Setup.create({ key: "enable_classroom_tab", value: "true" })
    Setup.create({ key: "enable_news_tab", value: "true" })
  end

end

