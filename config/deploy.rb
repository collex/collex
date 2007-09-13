# This defines a deployment "recipe" that you can feed to capistrano
# (http://manuals.rubyonrails.com/read/book/17). It allows you to automate
# (among other things) the deployment of your application.

# =============================================================================
# REQUIRED VARIABLES
# =============================================================================
# You must always specify the application and repository for every recipe. The
# repository must be the URL of the repository you want this recipe to
# correspond to. The deploy_to path must be the path on each machine that will
# form the root of the application path.

require 'mongrel_cluster/recipes'

if ENV['DEPLOY'] == 'production'
   puts "*** Deploying to the PRODUCTION servers!"
   set :application, "production-web"
   set :rails_env, "production"
   set :mongrel_port, "8000"
   set :mongrel_environment, "production"
else
   puts "*** Deploying to the STAGING server!"
   set :application, "staging-web"
   set :rails_env, "staging"
   set :mongrel_port, "8010"
   set :mongrel_environment, "staging"
end

set :sudo, "/usr/local/bin/sudo"
# set :svn_password, Proc.new { Capistrano::CLI.password_prompt('SVN Password: ') }
# set :repository, Proc.new { '--password "#{svn_password}" svn+ssh://erikhatcher@rubyforge.org/var/svn/subactive/collex'}
set :repository, "https://subversion.lib.virginia.edu/repos/patacriticism/collex/trunk/web"
set :deploy_to, "/usr/local/patacriticism/#{application}" # defaults to "/u/apps/#{application}"
set :user, "nines"            # defaults to the currently logged in user
set :rails_release, "rel_1-2-3"
set :rails_path, "#{shared_path}/vendor/#{rails_release}"

set :mongrel_conf, "/etc/mongrel_cluster/#{application}.yml"
# set :mongrel_rails, "/opt/csw/bin/mongrel_rails"
set :spinner_user, "nines"
set :mongrel_servers, 3
set :mongrel_address, "127.0.0.1"
# set :mongrel_conf, nil
set :mongrel_user, "nines"
set :mongrel_group, "staff"
# set :mongrel_prefix, nil
# set :mongrel_rails, 'mongrel_rails'
# set :mongrel_clean, false
set :mongrel_pid_file, "#{shared_path}/pids/mongrel.pid"
set :mongrel_log_file, "#{shared_path}/log/mongrel.log"
# set :mongrel_config_script, nil

# =============================================================================
# ROLES
# =============================================================================
# You can define any number of roles, each of which contains any number of
# machines. Roles might include such things as :web, or :app, or :db, defining
# what the purpose of each machine is. You can also specify options that can
# be used to single out a specific subset of boxes in a particular role, like
# :primary => true.

role :web, "jarry.itc.virginia.edu"
role :app, "jarry.itc.virginia.edu"
role :db,  "jarry.itc.virginia.edu", :primary => true

# =============================================================================
# OPTIONAL VARIABLES
# =============================================================================
set :rake, "/usr/local/bin/rake"
# set :scm, :darcs               # defaults to :subversion
set :svn, "/usr/local/bin/svn"       # defaults to searching the PATH
set :checkout, "export --ignore-externals"
# set :darcs, "/path/to/darcs"   # defaults to searching the PATH
# set :cvs, "/path/to/cvs"       # defaults to searching the PATH
# set :gateway, "gate.host.com"  # default to no gateway

# =============================================================================
# SSH OPTIONS
# =============================================================================
# ssh_options[:keys] = %w(/path/to/my/key /path/to/another/key)
# ssh_options[:port] = 25

# =============================================================================
# TASKS
# =============================================================================
# Define tasks that run on all (or only some) of the machines. You can specify
# a role (or set of roles) that each task should be executed on. You can also
# narrow the set of servers to a subset of a role by specifying options, which
# must match the options given for the servers to select (like :primary => true)

desc <<-DESC
An imaginary backup task. (Execute the 'show_tasks' task to display all
available tasks.)
DESC
task :backup, :roles => :db, :only => { :primary => true } do
  # the on_rollback handler is only executed if this task is executed within
  # a transaction (see below), AND it or a subsequent task fails.
  on_rollback { delete "/tmp/dump.sql" }

  run "mysqldump -u theuser -p thedatabase > /tmp/dump.sql" do |ch, stream, out|
    ch.send_data "thepassword\n" if out =~ /^Enter password:/
  end
end

# Tasks may take advantage of several different helper methods to interact
# with the remote server(s). These are:
#
# * run(command, options={}, &block): execute the given command on all servers
#   associated with the current task, in parallel. The block, if given, should
#   accept three parameters: the communication channel, a symbol identifying the
#   type of stream (:err or :out), and the data. The block is invoked for all
#   output from the command, allowing you to inspect output and act
#   accordingly.
# * sudo(command, options={}, &block): same as run, but it executes the command
#   via sudo.
# * delete(path, options={}): deletes the given file or directory from all
#   associated servers. If :recursive => true is given in the options, the
#   delete uses "rm -rf" instead of "rm -f".
# * put(buffer, path, options={}): creates or overwrites a file at "path" on
#   all associated servers, populating it with the contents of "buffer". You
#   can specify :mode as an integer value, which will be used to set the mode
#   on the file.
# * render(template, options={}) or render(options={}): renders the given
#   template and returns a string. Alternatively, if the :template key is given,
#   it will be treated as the contents of the template to render. Any other keys
#   are treated as local variables, which are made available to the (ERb)
#   template.

desc "Demonstrates the various helper methods available to recipes."
task :helper_demo do
  # "setup" is a standard task which sets up the directory structure on the
  # remote servers. It is a good idea to run the "setup" task at least once
  # at the beginning of your app's lifetime (it is non-destructive).
  setup

  buffer = render("maintenance.rhtml", :deadline => ENV['UNTIL'])
  put buffer, "#{shared_path}/system/maintenance.html", :mode => 0644
  sudo "killall -USR1 dispatch.fcgi"
  run "#{release_path}/script/spin"
  delete "#{shared_path}/system/maintenance.html"
end

# You can use "transaction" to indicate that if any of the tasks within it fail,
# all should be rolled back (for each task that specifies an on_rollback
# handler).

desc "A task demonstrating the use of transactions."
task :long_deploy do
  transaction do
    update_code
    disable_web
    symlink
    migrate
  end

  restart
  enable_web
end
##### END of EXAMPLES

desc "Set up the expected application directory structure on all boxes"
task :after_setup, :roles => [:app, :db, :web] do
  setup_rails
  setup_shared
end
desc "Setup the rails distribution"
task :setup_rails, :roles => [:app, :web] do
  run <<-CMD
    mkdir -p #{shared_path}/vendor &&
    #{svn} export http://dev.rubyonrails.org/svn/rails/tags/#{rails_release}/ #{rails_path}
  CMD
end

desc "Extra shared directories"
task :setup_shared, :roles => [:app, :web, :db] do
  run <<-CMD
    mkdir -p -m 775 #{shared_path}/tmp && 
    mkdir -p -m 750 #{shared_path}/config &&
    mkdir -p -m 750 #{shared_path}/config/environments
  CMD
end

# TODO this needs to check the remote system!
def rails_release_up_to_date?
  /#{rails_release}/ =~ `svn propget svn:externals vendor/`
end
task :before_update_code do
  unless rails_release_up_to_date?
    puts "\nWARNING ############################################### WARNING"
    puts "Update aborted."
    puts "Your local Rails version is different than #{rails_release}." 
    puts "Please update deploy.rb's rails_release property and run \"cap setup_rails\"."
    puts "WARNING ############################################### WARNING"
    abort
  end
end

desc "Custom stuff for after update_code"
task :after_update_code, :roles => [:app, :db] do
  run <<-CMD
    rm -rf #{release_path}/log; true &&
    rm -rf #{release_path}/tmp; true &&
    rm -rf #{release_path}/public/system; true &&
    ln -nfs #{shared_path}/log #{release_path}/log &&
    ln -nfs #{shared_path}/tmp #{release_path}/tmp &&
    cp -fp #{shared_path}/config/database.yml #{release_path}/config/database.yml &&
    ln -nfs #{shared_path}/system #{release_path}/public/system &&
    ln -nfs #{rails_path} #{release_path}/vendor/rails &&
    rm -rf #{release_path}/docs
  CMD
  
  sudo("chown webuser:staff #{release_path}/config/database.yml")
  #   send(run_method, "chmod -R g+w #{release_path}/web/")
  #   send(run_method, "chmod -R g+w #{release_path}/solr/logs/")
  #   send(run_method, "chmod -R g+w #{release_path}/solr/solr/")
  #   send(run_method, "chown -R www:www #{release_path}/")
end
desc <<-DESC
Rewritten for Collex's Solaris environment which won't break the old symlink. 
Update the 'current' symlink to point to the latest version of
the application's code.
DESC
task :symlink, :except => { :no_release => true } do
  on_rollback do 
    run "rm #{current_path}; true"
    run "ln -nfs #{previous_release} #{current_path}" 
  end
  run "rm #{current_path}; true"
  run "ln -nfs #{current_release} #{current_path}"
end
desc <<-DESC
Rewritten for Collex's Solaris environment which won't break old symlink.
Rollback the latest checked-out version to the previous one by fixing the
symlinks and deleting the current release from all servers.
DESC
task :rollback_code, :except => { :no_release => true } do
  if releases.length < 2
    raise "could not rollback the code because there is no prior release"
  else
    run <<-CMD
      rm #{current_path}; true &&
      ln -nfs #{previous_release} #{current_path} &&
      rm -rf #{current_release}
    CMD
  end
end
task :restart, :roles => :app do
 sudo "/usr/apache/bin/apachectl graceful"
end

task :before_start_mongrel_cluster do
  set :use_sudo, false
end
task :after_start_mongrel_cluster do
  set :use_sudo, true
end

task :before_stop_mongrel_cluster do
  set :use_sudo, false
end
task :after_stop_mongrel_cluster do
  set :use_sudo, true
end

task :before_restart_mongrel_cluster do
  set :use_sudo, false
end
task :after_restart_mongrel_cluster do
  set :use_sudo, true
end