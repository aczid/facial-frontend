default_run_options[:pty] = true
set :application, "nfi_frontend"
set :repository,  "git://github.com/fis-nfi-2008/facial-frontend.git"
set :scm, "git"
set :scm_passphrase, "blaat"
set :user, "aczid"
set :branch, "master"
set :git_shallow_clone, 1
set :use_sudo, false

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
#set :deploy_to, "/var/www/#{application}"
set :deploy_to, "/home/aczid/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, "redbull.mine.nu"
role :web, "redbull.mine.nu"
role :db,  "redbull.mine.nu", :primary => true

desc "Link in the production extras" 
task :after_symlink do
    # symlink log path
  run "ln -nfs #{shared_path}/log #{release_path}/log" 
    # symlink path to database, this is only needed if you are using sqlite (which is ok for little things and is really easy)
  #run "ln -nfs #{shared_path}/db/#{application}_production.sqlite3 #{release_path}/db/#{application}_production.sqlite3" 
end

desc "Restart Passenger apache2 module"
deploy.task :restart do
  `touch #{deploy_to}/tmp/restart.txt`
end
