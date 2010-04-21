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

require 'ftools'

namespace :collex do

  desc "Run JSLint on all js files"
  task :jslint => :environment do
		ext = '.js'
		skip_ext = '-min.js'
		Dir.foreach("#{RAILS_ROOT}/public/javascripts") { |f|
			if f.index(ext) == f.length - ext.length && f.index(skip_ext) != f.length - skip_ext.length
				if f != 'prototype.js' && f != 'controls.js' && f != 'effects.js'
					puts "Linting #{f}..."
					system("#{JAVA_PATH}java -jar #{RAILS_ROOT}/lib/tasks/rhino1_7R2_js.jar #{RAILS_ROOT}/lib/tasks/fulljslint.js #{RAILS_ROOT}/public/javascripts/#{f}")
				end
			end
		}
	end

	def stop_daemons
		puts "Stopping all daemons..."
		`script/daemons stop`
		sleep(8)
	end

	def start_daemons
		puts "Starting all daemons..."
		`script/daemons start`
	end

	def deploy_on_production
		puts "Deploy latest version on production..."
		stop_daemons()
		version = Branding.version()
		puts "You will be asked for your mysql password."
		`mysqldump nines_production -u nines -p > ~/backup_#{version}.sql`
		update_ninesperf()
		Rake::Task['collex:tag_current_version'].invoke
		start_daemons()
	end

	def update_ninesperf
		puts "Update site from repository..."
		stop_daemons()
		`svn up`
		Rake::Task['collex:update_nines_theme'].invoke
		Rake::Task['db:migrate'].invoke
		Rake::Task['collex:compress_css_js'].invoke
		puts "You will be asked for your sudo password."
		`sudo /sbin/service httpd restart`
		start_daemons()
	end

	def update_18th
		puts "Update site from repository..."
		stop_daemons()
		`svn up`
		Rake::Task['collex:update_nines_theme'].invoke
		Rake::Task['db:migrate'].invoke
		Rake::Task['collex:compress_css_js'].invoke
		puts "You will be asked for your sudo password."
		`sudo /sbin/service httpd restart`
		start_daemons()
	end

	def update_experimental
		# TODO-PER: Can we force this to run in development mode?
		puts "Update site from repository..."
		stop_daemons()
		`svn up`
		Rake::Task['collex:update_nines_theme'].invoke
		Rake::Task['db:migrate'].invoke
		Rake::Task['collex:compress_css_js'].invoke
		`mongrel_rails restart`
		start_daemons()
	end

	def update_indexing
		puts "Update site from repository..."
		stop_daemons()
		`svn up`
		Rake::Task['collex:update_nines_theme'].invoke
		Rake::Task['db:migrate'].invoke
		Rake::Task['collex:compress_css_js'].invoke
		`mongrel_rails restart`	#TODO-PER: See if this machine is actually using the service instead of mongrel!
		start_daemons()
	end

	def update_development
		puts "Update site from repository..."
		stop_daemons()
		`svn up`
		Rake::Task['db:migrate'].invoke
		Rake::Task['collex:compress_about_css'].invoke
		`mongrel_rails restart`
		start_daemons()
	end

	desc "Do all tasks that routinely need to be done when anything changes in the source repository -- the style of update is in site.yml"
	task :update => :environment do
		puts "Update type: #{UPDATE_TASK}"
		if UPDATE_TASK == 'production'
			deploy_on_production()
		elsif UPDATE_TASK == 'indexing'
			update_indexing()
		elsif UPDATE_TASK == 'nines.perf'
			update_ninesperf()
		elsif UPDATE_TASK == 'development'
			update_development()
		elsif UPDATE_TASK == 'experimental'
			update_experimental()
		elsif UPDATE_TASK == '18th'
			update_18th()
		else
			puts "Unknown updating type. Compare the value in config/site.yml and the list in the collex:update rake task (file: collex.rake)."
		end
	end

	#
	# All tasks below here are not normally called separately, but can be if needed. They are called as part of the
	# tasks defined above.
	#

	def safe_mkdir(folder)
		begin
	    Dir.mkdir(folder)
		rescue
			# It's ok to fail: it probably means the folder already exists.
		end
	end
	
  desc "Update the installed Collex Wordpress theme"
  task :update_nines_theme do
		puts "Updating wordpress files..."
		safe_mkdir("#{RAILS_ROOT}/public/wp")
		safe_mkdir("#{RAILS_ROOT}/public/wp/wp-content")
		safe_mkdir("#{RAILS_ROOT}/public/wp/wp-content/themes")
		safe_mkdir("#{RAILS_ROOT}/public/wp/wp-content/themes/nines")
    copy_dir( "#{RAILS_ROOT}/wordpress_theme", "#{RAILS_ROOT}/public/wp/wp-content/themes/nines" )
  end

  def copy_dir( start_dir, dest_dir )
     puts "Copying the contents of #{start_dir} to #{dest_dir}..."
     Dir.new(start_dir).each { |file|
       unless file =~ /\A\./
#         start_file = "#{start_dir}/#{file}"
#         dest_file = "#{dest_dir}/#{file}"
         File.copy("#{start_dir}/#{file}", "#{dest_dir}/#{file}")
       end
     }
  end

	desc "Tag this version in SVN"
	task :tag_current_version => :environment do
		# This uses the current version number as the name of the tag. If that tag already exists, a letter is appended to it so that it is unique.
		# version = Branding.version() -- may report one version behind if we just updated.
		# Read the version directly because we might have just done an "svn up" and so we are actually running one version behind.
		version = ""
		File.open("#{RAILS_ROOT}/app/models/branding.rb", "r") do |file|
			wants_this = false
			while line = file.gets
				if wants_this && version.length == 0
					arr = line.split("\"")
					version = arr[1]
				elsif line.index("self.version") != nil
					wants_this = true
				end
			end
		end

		if version.length == 0
			puts "Can't tag version because the format of branding.rb"
		else
			output = `svn info https://subversion.lib.virginia.edu/repos/patacriticism/collex/tags/#{version}`
			if output.index("Path: #{version}") == 0	# the tag already exists, so bump up the tag version
				finished = false
				letter = 'a'
				while !finished
					output = `svn info https://subversion.lib.virginia.edu/repos/patacriticism/collex/tags/#{version}#{letter}`
					finished = output.index("Path: #{version}#{letter}") != 0
					letter[0] = letter[0]+1 if !finished
				end
				version += letter
			end
			puts "Tagging version #{version}..."
			system("svn copy -rHEAD -m tag https://subversion.lib.virginia.edu/repos/patacriticism/collex/trunk/web https://subversion.lib.virginia.edu/repos/patacriticism/collex/tags/#{version}")
		end
	end

	desc "Compress the css for the about pages"
	task :compress_about_css => :environment do
		compress_file('stylesheets', '.css', "")
		compress_file("stylesheets/#{SKIN}", '.css', "#{SKIN}__")
		concatenate_css(:about)
	end

  desc "Compress all css and js files"
  task :compress_css_js => :environment do
		# The purpose of this is to roll all our css and js files into one minimized file so that load time on the server is as short as
		# possible. Using this method allows different pages to have different sets of includes, and allows the developer to create
		# as many small css and js files as they want. See get_include_file_list.rb for details.
		compress_file('javascripts', '.js', "")
		#compress_file("javascripts/#{SKIN}", '.js', "#{SKIN}__")
		compress_file('stylesheets', '.css', "")
		compress_file("stylesheets/#{SKIN}", '.css', "#{SKIN}__")

		concatenate_js(:my_collex)
		concatenate_css(:my_collex)
		concatenate_js(:search)
		concatenate_css(:search)
		concatenate_js(:tag)
		concatenate_css(:tag)
		concatenate_js(:discuss)
		concatenate_css(:discuss)
		concatenate_js(:home)
		concatenate_css(:home)
		concatenate_js(:exhibits)
		concatenate_css(:exhibits)
		concatenate_js(:shared)
		concatenate_css(:shared)
		concatenate_js(:admin)
		concatenate_css(:admin)
		concatenate_js(:about)
		concatenate_css(:about)
		concatenate_js(:news)
		concatenate_css(:news)
		concatenate_js(:view_exhibit)
		concatenate_css(:view_exhibit)
		concatenate_js(:print_exhibit)
		concatenate_css(:print_exhibit)
	end

	def time_format(tim)
		return tim.getlocal().strftime("%b %d, %Y %I:%M%p")
	end

	def compress_file(folder, ext, prefix)
		Dir.foreach("#{RAILS_ROOT}/public/#{folder}") { |f|
			if f.index(ext) == f.length - ext.length
				fname = f.slice(0, f.length - ext.length)
				if fname.index('-min') != fname.length - 4
					src_path = "#{RAILS_ROOT}/public/#{folder}/#{f}"
					dst_path = "#{RAILS_ROOT}/tmp/#{prefix}#{fname}-min#{ext}"
					src_time = File.stat(src_path).mtime
					begin
						dst_time = File.stat(dst_path).mtime
					rescue
						# It's ok if the file doesn't exist; that means that we should definitely recreate it.
						dst_time = 10.years.ago
					end
					if src_time > dst_time
						puts "Compressing #{f}..."
						system("#{JAVA_PATH}java -jar #{RAILS_ROOT}/lib/tasks/yuicompressor-2.4.2.jar --line-break 7000 -o #{dst_path} #{src_path}")
					else
						puts "Skipping #{f}. Source time=#{time_format(src_time)}; Dest time=#{time_format(dst_time)}"
					end
				end
			end
		}
	end

	def concatenate_js(page)
		list_proto = []
		fnames = GetIncludeFileList.get_js(page)
		fnames[:prototype].each { |f|
			list_proto.push("#{RAILS_ROOT}/tmp/#{f}-min.js")
		}

		list = []
		fnames[:local].each { |f|
			f =
			list.push("#{RAILS_ROOT}/tmp/#{f.gsub('/','__')}-min.js")
		}

		dest ="javascripts/#{page.to_s()}-min.js"
		puts "Creating #{dest}..." # [\n\t#{list.join("\n\t")}]"
		system("cat #{list_proto.join(' ')} > #{RAILS_ROOT}/public/javascripts/prototype-min.js")
		system("cat #{list.join(' ')} > #{RAILS_ROOT}/public/#{dest}")
	end

	def concatenate_css(page)
		list = []
		fnames = GetIncludeFileList.get_css(page)
		fnames[:local].each { |f|
			list.push("#{RAILS_ROOT}/tmp/#{f.gsub('/','__')}-min.css")
		}
		dest ="stylesheets/#{page.to_s()}-min.css"
		puts "Creating #{dest}..." # [\n\t#{list.join("\n\t")}]"
		list = list.join(' ')
		system("cat #{list} > #{RAILS_ROOT}/public/#{dest}")
	end

	desc "Automatically put users in a group"
	task :join_users_to_group => :environment do
		group_name = "ENGL 227"
		group = Group.find_by_name(group_name)
		if group == nil
			puts "Can't find the group: #{group_name}"
		else

			exhibit_names = [
				"Broxterman ENGL 227 Project",
				"Langwell ENGL 227 Project",
				"Rafferty ENGL227 Project",
				"Slaughter ENGL 227 PROJECT",
				"Stockton ENGL 227 Project",
				"Culp ENGL 227 Project",
				"Ince ENGL 227 Project",
				"Waggoner ENGL 227 Project",
				"Wolfshohl ENGL 227 Project",
				"Carney ENGL 227 Project- The Hypocrisy of Christianity in Slavery",
				"Sanders ENGL 227 Project",
				"Brock ENGL 227 Project",
				"Tarver ENGL 227 Project",
				"Felix ENGL 227 Project",
				"Valenta ENGL 227 Project",
				"Wise, ENGL 227 Project",
				"Thornton ENGL 227 Project",
				"Jones English 227",
				"Martensson english 227 Project",
				"Cardenas ENGL 227",
				"O'Connor ENGL 227",
				"Herron English 227",
				"AStewart engl227",
				"Brown ENGL 227",
				"Horn English 227",
				"skrla english 227",
				"Glaesmann, Clint English 227",
				"Gerlach English 227",
				"Godsey English 227",
				"Rogers ENGL 227",
				"Mitchell english 227",
				"Venegas english 227",
				"Lisle english 227",
				"McClure ENGL 227",
				"DeLeon English 227",
				"Swanson English 227",
				"weber english 227",
				"Wells English 227",
				"Orth Engl 227",
				"Luza English 227",
				"Willis ENG 227 Project",
				"Potts Engl 227 Project",
				"Baker English 227 Project",
				"Davenport - Development and Understanding of the Native American Through Early American Literature",
				"A Woman's Place By Ashley Arevalo ENGL 227",
				"Welsh ENGL 227",
				"marroquin ENGL 227 Project",
				"Pearson English 227",
				"Tollett English 227",
				"Turner English 227",
				"Pratt ENGL 227",
				"Coryanne ENGL 227",
				"Violence in Slavery",
				"Stephenson English 227 Project",
				"ENGL 227-Cooper",
				"Spotts ENGL 227",
				"Engl 227 project",
				"Rekoff ENGL 227",
				"Allen Class Project ENGL 227",
				"American Independence ENGL 227",
				"Brown ENGL 227",
				"Ridley ENGL 227 Project",
				"Buehler Eng 227",
				"Earhart, Collex Project",
				"Garrett ENGL 227 Project",
				"Stuberfield, Class Project ENG 227",
				"Domains and Domesticity - Class Project ENG 227",
				"Brady Wright ENGL 227 project",
				"jthompson227F09",
				"ABell ENGL 227F09",
				"M Torres 227F09",
				"tayer 227F09",
				"rbounds 227f09",
				"V Goussen 227F09",
				"astephens227F09",
				"mlaman_227F09",
				"tmoore227F09",
				"MKasper227F09",
				"Jroznos227F09",
				"Koontz ENGL 227 Project",
				"jreardon227F09",
				"ABuitron227F09",
				"SFraleigh227F09",
				"MAdams227F09",
				"pgarrett227F09",
				"B. Holder 227F09",
				"jhuff227F09",
				"bfulmer227F09",
				"APatton227F09",
				"Early American Magazines AElder 227F09",
				"EHuey ENGL 227 Project F09",
				"ASwanberg227F09",
				"MWalston227F09",
				"MFelts ENGL227F09",
				"MBrewster 227 F09",
				"Risher ENGL 227 Project",
				"btnguyen227F09",
				"TSepe-22F09",
				"K.McClainENG227",
				"kpurgatorio227F09",
				"BContreras 227F09"
			]

			exhibit_names.each{ |name|
				exhibit = Exhibit.find_by_title(name)
				if exhibit == nil
					puts "Can't find the exhibit: #{name}"
				else
					user_id = exhibit.user_id
					GroupsUser.auto_join(group.id, user_id)
					exhibit.group_id = group.id
					exhibit.save
				end
			}
		end
	end

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
end

