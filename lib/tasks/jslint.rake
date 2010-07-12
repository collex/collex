namespace :jslint do

	desc "Run JSLint on all js files"
	task :all do
		ext = '.js'
		skip_ext = '-min.js'
		Dir.foreach("#{RAILS_ROOT}/public/javascripts") { |f|
			if f.index(ext) == f.length - ext.length && f.index(skip_ext) != f.length - skip_ext.length
				if f != 'prototype.js' && f != 'controls.js' && f != 'effects.js'
					lint_one(f)
				end
			end
		}
	end

	desc "Run JSLint on one js file"
	task :file do
		name = ENV['file']
		if name == nil
			puts "Usage: rake file=xxxx jslint:all (file should not contain the full path or .js)"
		else
			lint_one(name+'.js')
		end
	end

	desc "Analyze the dependencies in all the JS files."
	task :dependencies do
		ext = '.js'
		skip_ext = '-min.js'
		Dir.foreach("#{RAILS_ROOT}/public/javascripts") { |f|
			if f.index(ext) == f.length - ext.length && f.index(skip_ext) != f.length - skip_ext.length
				if f != 'prototype.js' && f != 'controls.js' && f != 'effects.js'
					globals, externs = get_dependency_info(f)
				end
			end
		}
	end

	def get_dependency_info(f)
		# scan the file for /*extern and /*global lines.
	end

	def lint_one(fname)
		full_path = "#{RAILS_ROOT}/public/javascripts/#{fname}"
		puts "Linting #{fname} (#{full_path})..."
		system("java -jar #{RAILS_ROOT}/lib/tasks/rhino1_7R2_js.jar #{RAILS_ROOT}/lib/tasks/fulljslint.js #{full_path}")
	end
end
