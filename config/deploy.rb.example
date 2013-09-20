# To deploy:
# cap edge_nines
# cap edge_18th
# cap edge_mesa
# cap prod_nines
# cap prod_18th
# cap prod_mesa

require 'rvm/capistrano'
require 'bundler/capistrano'
require "delayed/recipes"
require "whenever/capistrano"

# Read in the site-specific information so that the initializers can take advantage of it.
config_file = "config/site.yml"
if File.exists?(config_file)
	set :site_specific, YAML.load_file(config_file)['capistrano']
else
	puts "***"
	puts "*** Failed to load capistrano configuration. Did you create #{config_file} with a capistrano section?"
	puts "***"
end

set :repository, "git://github.com/collex/collex.git"
set :scm, "git"
set :branch, "master"
set :deploy_via, :remote_cache

set :use_sudo, false

set :normalize_asset_timestamps, false

set :rails_env, "production"

set :whenever_command, "bundle exec whenever"

#set :whenever_command, "bundle exec whenever"

desc "Print out a menu of all the options that a user probably wants."
task :menu do
	tasks = {
		'1' => { name: "cap edge_nines", computer: 'edge', skin: 'nines' },
		'2' => { name: "cap edge_18th", computer: 'edge', skin: '18th' },
		'3' => { name: "cap edge_mesa", computer: 'edge', skin: 'mesa' },
		'4' => { name: "cap prod_nines", computer: 'prod', skin: 'nines' },
		'5' => { name: "cap prod_18th", computer: 'prod', skin: '18th' },
		'6' => { name: "cap prod_mesa", computer: 'prod', skin: 'mesa' }
	}

	tasks.each { |key, value|
		puts "#{key}. #{value[:name]}"
	}

	print "Choose deployment type: "
	begin
		system("stty raw -echo")
		option = STDIN.getc
	ensure
		system("stty -raw echo")
	end
	puts ""

	value = tasks[option]
	if !value.nil?
		set_application(value[:computer], value[:skin])
		puts "Deploying..."
		after :menu, 'deploy'
	else
		puts "Not deploying. Please enter a value from 1 - 9."
	end
end

def set_application(section, skin)
	set :deploy_to, "#{site_specific[section]['deploy_base']}/#{skin}"
	set :application, site_specific[section]['ssh_name']
	set :user, site_specific[section]['user']
	set :rvm_ruby_string, site_specific[section]['ruby']
	if site_specific[section]['system_rvm']
		set :rvm_type, :system
	end

	role :web, "#{application}"                          # Your HTTP server, Apache/etc
	role :app, "#{application}"                          # This may be the same as your `Web` server
	role :db,  "#{application}", :primary => true 		# This is where Rails migrations will run
	set :skin, skin
end

desc "Run tasks to update edge NINES environment."
task :edge_nines do
	set_application('edge', 'nines')
end

desc "Run tasks to update edge 18thConnect environment."
task :edge_18th do
	set_application('edge', '18th')
end

desc "Run tasks to update edge Mesa environment."
task :edge_mesa do
	set_application('edge', 'mesa')
end

desc "Run tasks to update production NINES environment."
task :prod_nines do
	set_application('prod', 'nines')
end

desc "Run tasks to update production 18thConnect environment."
task :prod_18th do
	set_application('prod', '18th')
end

desc "Run tasks to update production Mesa environment."
task :prod_mesa do
	set_application('prod', 'mesa')
end

namespace :passenger do
	desc "Restart Application"
	task :restart do
		run "touch #{current_path}/tmp/restart.txt"
	end
end

namespace :config do
	desc "Config Symlinks"
	task :symlinks do
		run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
		run "ln -nfs #{shared_path}/config/site.yml #{release_path}/config/site.yml"
		run "ln -nfs #{shared_path}/photos_small #{release_path}/public/photos_small"
		run "ln -nfs #{shared_path}/photos_full #{release_path}/public/photos_full"
	end

	desc "Wordpress Symlinks"
	task :wordpress do
		run "ln -nfs /home/#{user}/www/wp_#{skin}_news #{release_path}/public/news"
		run "ln -nfs /home/#{user}/www/wp_#{skin}_about #{release_path}/public/about"
	end
end

namespace :skinning do
	desc "Copy all static files to the public path"
	task :static do
		puts "Updating static files..."
		source_dir = "#{release_path}/public/static/#{skin}"
		dest_dir = "#{release_path}/public"
		run "ln -nfs #{source_dir}/404.html #{dest_dir}/404.html"
		run "ln -nfs #{source_dir}/422.html #{dest_dir}/422.html"
		run "ln -nfs #{source_dir}/500.html #{dest_dir}/500.html"
		run "ln -nfs #{source_dir}/favicon.ico #{dest_dir}/favicon.ico"
		run "ln -nfs #{source_dir}/help.html #{dest_dir}/help.html"
		run "ln -nfs #{source_dir}/index_underconstruction.html #{dest_dir}/index_underconstruction.html"
	end
end

after :edge_nines, 'deploy'
after :edge_18th, 'deploy'
after :edge_mesa, 'deploy'
after :prod_nines, 'deploy'
after :prod_18th, 'deploy'
after :prod_mesa, 'deploy'
after :deploy, "deploy:migrate"

after "deploy:stop",    "delayed_job:stop"
after "deploy:start",   "delayed_job:start"
after "deploy:restart", "delayed_job:restart"
after "deploy:finalize_update", "config:symlinks"
after "deploy:finalize_update", "config:wordpress"
after "deploy:finalize_update", "skinning:static"
after :deploy, "passenger:restart"

reset = "\033[0m"
green = "\033[32m" # Green
red = "\033[31m" # Bright Red

desc "Set up the edge nines server."
task :edge_nines_setup do
	set_application('edge', 'nines')
end
after :edge_nines_setup, 'deploy:setup'

desc "Set up the edge 18th server."
task :edge_18th_setup do
	set_application('edge', '18th')
end
after :edge_18th_setup, 'deploy:setup'

desc "Set up the edge mesa server."
task :edge_mesa_setup do
	set_application('edge', 'mesa')
end
after :edge_mesa_setup, 'deploy:setup'

desc "Set up the edge nines server."
task :prod_nines_setup do
	set_application('prod', 'nines')
end
after :prod_nines_setup, 'deploy:setup'

desc "Set up the edge 18th server."
task :prod_18th_setup do
	set_application('prod', '18th')
end
after :prod_18th_setup, 'deploy:setup'

desc "Set up the edge mesa server."
task :prod_mesa_setup do
	set_application('prod', 'mesa')
end
after :prod_mesa_setup, 'deploy:setup'

desc "Set up the edge server's config."
task :setup_config do
	run "mkdir #{shared_path}/config"
	run "touch #{shared_path}/config/database.yml"
	run "touch #{shared_path}/config/site.yml"
	puts ""
	puts "#{red}!!!"
	puts "!!! Now create the database.yml and site.yml files in the shared folder on the server."
	puts "!!! Also create the database in mysql."
	puts "!!!#{reset}"
end

after 'deploy:setup', :setup_config
