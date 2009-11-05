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

  desc "Update the installed NINES Wordpress theme"
  task :update_nines_theme do
		begin
	    Dir.mkdir("#{RAILS_ROOT}/public/wp/wp-content/themes/nines")
		rescue
			# It's ok to fail: it probably means the folder already exists.
		end
    copy_dir( "#{RAILS_ROOT}/wordpress_theme", "#{RAILS_ROOT}/public/wp/wp-content/themes/nines" )
  end
  
  desc "Install the NINES Wordpress theme"
  task :install_nines_theme do    
    # install php files
    Dir.mkdir("#{RAILS_ROOT}/public/wp/wp-content/themes/nines")
    copy_dir( "#{RAILS_ROOT}/wordpress_theme", "#{RAILS_ROOT}/public/wp/wp-content/themes/nines" );        
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
		version = Branding.version()
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

	desc "Deploy on production"
	task :deploy_on_production => :environment do
		puts "Deploy latest version on production..."
		version = Branding.version()
		`mysqldump nines_production -u nines -p > ~/backup_#{version}.sql`
		Rake::Task['collex:tag_current_version'].invoke
		`svn up`
		Rake::Task['collex:update_site'].invoke
		`sudo /sbin/service httpd restart`
	end

	desc "Do all tasks that routinely need to be done when anything changes in the source repository"
	task :total_update_site do
		puts "Update site from repository..."
		system("svn up")
		Rake::Task['collex:update_site'].invoke
		`sudo /sbin/service httpd restart`
	end

	desc "Do all tasks that routinely need to be done when anything changes in the source repository"
	task :update_site do
		Rake::Task['collex:update_nines_theme'].invoke
		Rake::Task['db:migrate'].invoke
		Rake::Task['collex:compress_css_js'].invoke
	end

	desc "Compress the css for the about pages"
	task :compress_about_css => :environment do
		compress_file('stylesheets', '.css')
		concatenate_css(:about)
	end

  desc "Compress all css and js files"
  task :compress_css_js => :environment do
		# The purpose of this is to roll all our css and js files into one minimized file so that load time on the server is as short as
		# possible. Using this method allows different pages to have different sets of includes, and allows the developer to create
		# as many small css and js files as they want. See get_include_file_list.rb for details.
		compress_file('javascripts', '.js')
		compress_file('stylesheets', '.css')

		concatenate_js(:my9s)
		concatenate_css(:my9s)
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
		concatenate_js(:admin)
		concatenate_css(:admin)
		concatenate_js(:about)
		concatenate_css(:about)
		concatenate_js(:view_exhibit)
		concatenate_css(:view_exhibit)
		concatenate_js(:print_exhibit)
		concatenate_css(:print_exhibit)
	end

	def compress_file(folder, ext)
		Dir.foreach("#{RAILS_ROOT}/public/#{folder}") { |f|
			if f.index(ext) == f.length - ext.length
				fname = f.slice(0, f.length - ext.length)
				if fname.index('-min') != fname.length - 4
					puts "Compressing #{f}..."
					system("#{JAVA_PATH}java -jar #{RAILS_ROOT}/lib/tasks/yuicompressor-2.4.2.jar --line-break 7000 -o #{RAILS_ROOT}/tmp/#{fname}-min#{ext} #{RAILS_ROOT}/public/#{folder}/#{f}")
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
			list.push("#{RAILS_ROOT}/tmp/#{f}-min.js")
		}

		dest ="javascripts/#{page.to_s()}-min.js"
		puts "Creating #{dest}..."
		system("cat #{list_proto.join(' ')} > #{RAILS_ROOT}/public/javascripts/prototype-min.js")
		system("cat #{list.join(' ')} > #{RAILS_ROOT}/public/#{dest}")
	end

	def concatenate_css(page)
		list = []
		fnames = GetIncludeFileList.get_css(page)
		fnames[:local].each { |f|
			list.push("#{RAILS_ROOT}/tmp/#{f}-min.css")
		}
		dest ="stylesheets/#{page.to_s()}-min.css"
		list = list.join(' ')
		puts "Creating #{dest}..."
		system("cat #{list} > #{RAILS_ROOT}/public/#{dest}")
	end

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

	desc "Fix character set from CP1252 to utf-8"
	task :fix_char_set => :environment do
		CharSetAlter.downcase_tag()
		debug = false
		CharSetAlter.cp1252_to_utf8(ExhibitElement, :element_text, debug)
		CharSetAlter.cp1252_to_utf8(ExhibitElement, :element_text2, debug)
		CharSetAlter.cp1252_to_utf8(ExhibitFootnote, :footnote, debug)
		CharSetAlter.cp1252_to_utf8(ExhibitIllustration, :illustration_text, debug)
		CharSetAlter.cp1252_to_utf8(ExhibitIllustration, :caption1, debug)
		CharSetAlter.cp1252_to_utf8(ExhibitIllustration, :caption2, debug)
		CharSetAlter.cp1252_to_utf8(CachedProperty, :value, debug)
		CharSetAlter.cp1252_to_utf8(CollectedItem, :annotation, debug)
		CharSetAlter.cp1252_to_utf8(DiscussionComment, :comment, debug)
		CharSetAlter.cp1252_to_utf8(DiscussionThread, :title, debug)
		CharSetAlter.cp1252_to_utf8(DiscussionTopic, :description, debug)
		CharSetAlter.cp1252_to_utf8(Search, :name, debug)
		CharSetAlter.cp1252_to_utf8(Tag, :name, debug)
		CharSetAlter.cp1252_to_utf8(User, :username, debug)
		CharSetAlter.cp1252_to_utf8(User, :fullname, debug)
		CharSetAlter.cp1252_to_utf8(User, :about_me, debug)
	end
end

