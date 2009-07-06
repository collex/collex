require 'ftools'

namespace :collex do
  
  desc "Update the installed NINES Wordpress theme"
  task :update_nines_theme do
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
         start_file = "#{start_dir}/#{file}"
         dest_file = "#{dest_dir}/#{file}"  
         File.copy("#{start_dir}/#{file}", "#{dest_dir}/#{file}")
       end     
     }    
  end

	desc "Get the latest code from SVN"
	task :update_repository do
		puts "Update site from repository..."
		system("svn up")
	end

	desc "Do all tasks that routinely need to be done when anything changes in the source repository"
	task :update_site do
		Rake::Task['collex:update_repository'].invoke
		Rake::Task['collex:update_nines_theme'].invoke
		Rake::Task['db:migrate'].invoke
		Rake::Task['collex:compress_css_js'].invoke
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
	end

	def compress_file(folder, ext)
		Dir.foreach("#{RAILS_ROOT}/public/#{folder}") { |f|
			if f.index(ext) == f.length - ext.length
				fname = f.slice(0, f.length - ext.length)
				if fname.index('-min') != fname.length - 4
					puts "Compressing #{f}..."
					system("java -jar #{RAILS_ROOT}/lib/tasks/yuicompressor-2.4.2.jar --line-break 7000 -o #{RAILS_ROOT}/tmp/#{fname}-min#{ext} #{RAILS_ROOT}/public/#{folder}/#{f}")
				end
			end
		}
	end

	def concatenate_js(page)
		list = []
		fnames = GetIncludeFileList.get_js(page)
		fnames[:pre_local].each { |f|
			list.push("#{RAILS_ROOT}/tmp/#{f}-min.js")
		}
#		fnames[:yui].each { |f|
#			#File.copy("#{RAILS_ROOT}/public#{f}-min.js", "#{RAILS_ROOT}/tmp#{f.split('/')[f.split('/').length-1]}-min.js")
#			list.push("#{RAILS_ROOT}/public#{f}-min.js")
#		}
		fnames[:local].each { |f|
			list.push("#{RAILS_ROOT}/tmp/#{f}-min.js")
		}

		dest ="javascripts/#{page.to_s()}-min.js"
		list = list.join(' ')
		puts "Creating #{dest}..."
		system("cat #{list} > #{RAILS_ROOT}/public/#{dest}")
	end

	def concatenate_css(page)
		list = []
		fnames = GetIncludeFileList.get_css(page)
#		fnames[:yui].each { |f|
#			list.push("#{RAILS_ROOT}/public#{f}-min.css")
#		}
		fnames[:local].each { |f|
			list.push("#{RAILS_ROOT}/tmp/#{f}-min.css")
		}
		dest ="stylesheets/#{page.to_s()}-min.css"
		list = list.join(' ')
		puts "Creating #{dest}..."
		system("cat #{list} > #{RAILS_ROOT}/public/#{dest}")
	end
end

