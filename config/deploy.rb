# To deploy:
# cap edge_nines
# cap edge_18th
# cap edge_mesa

require 'rvm/capistrano'
set :rvm_ruby_string, 'ruby-1.9.3-p0'
#set :rvm_type, :system

require 'bundler/capistrano'
require "delayed/recipes"
#require "whenever/capistrano"

set :repository, "git://github.com/collex/collex.git"
set :scm, "git"
set :branch, "master"
set :deploy_via, :remote_cache

set :user, "arc"
set :use_sudo, false

set :normalize_asset_timestamps, false

set :rails_env, "production"

#set :whenever_command, "bundle exec whenever"
def set_application()
	role :web, "#{application}"                          # Your HTTP server, Apache/etc
	role :app, "#{application}"                          # This may be the same as your `Web` server
	role :db,  "#{application}", :primary => true 		# This is where Rails migrations will run

end

desc "Run tasks to update edge NINES environment."
task :edge_nines do
	set :application, "edge.nines.org"
	set :deploy_to, "/home/arc/www/nines"
	set :skin, 'nines'
	set_application()
end

desc "Run tasks to update edge 18thConnect environment."
task :edge_18th do
	set :application, "edge.18thconnect.org"
	set :deploy_to, "/home/arc/www/18th"
	set :skin, 'nines'
	set_application()
end

desc "Run tasks to update edge Mesa environment."
task :edge_mesa do
	set :application, "mesa.performantsoftware.com"
	set :deploy_to, "/home/arc/www/mesa"
	set :skin, 'nines'
	set_application()
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
		run "ln -nfs #{shared_path}/config/daemons.yml #{release_path}/config/daemons.yml"
	end

	desc "Wordpress Symlinks"
	task :wordpress do
		run "ln -nfs /home/#{user}/www/wp_#{skin}_news #{release_path}/public/news"
		run "ln -nfs /home/#{user}/www/wp_#{skin}_about #{release_path}/public/about"
	end
end

namespace :daemons do
	task :restart, :roles => :app do
		run "echo Restarting all daemons..."
		run "#{release_path}/lib/daemons/mailer_ctl restart"
		run "#{release_path}/lib/daemons/session_cleaner_ctl restart"
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
after :deploy, "deploy:migrate"

after "deploy:stop",    "delayed_job:stop"
after "deploy:start",   "delayed_job:start"
after "deploy:restart", "delayed_job:restart"
after "deploy:finalize_update", "config:symlinks"
after "deploy:finalize_update", "config:wordpress"
after "deploy:finalize_update", "daemons:restart"
after "deploy:finalize_update", "skinning:static"
after :deploy, "passenger:restart"
