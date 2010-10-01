# RVM Settings
$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require "rvm/capistrano"
set :rvm_ruby_string, "1.9.2"
set :rvm_type, :system

# Server Name
set :server_name, "___.blueboxgrid.com"

# Application Settings
set :application, ""
set :repository,  "git://github.com/blueboxjesse/demo_rails3_deploy_app.git"

# Generall Settings
set :scm, "git"
default_run_options[:pty] = true
set :checkout, 'export'

set :user, "deploy"

set :deploy_to, "/srv/#{application}"
set :use_sudo, false

role :app, server_name
role :web, server_name
role :db,  server_name, :primary => true

set :keep_releases, 3
after "deploy", "deploy:cleanup"
after "deploy:update_code", "deploy:secondary_symlink"
after 'deploy:secondary_symlink', 'bundler:bundle_new_release'

namespace :deploy do

	task :secondary_symlink do
		run "rm -f #{release_path}/config/database.yml"
		run "ln -s #{deploy_to}/shared/config/database.yml #{release_path}/config/database.yml"
	end

	task :restart do
		run "touch #{deploy_to}/current/tmp/restart.txt"
	end

	task :start do
		run "touch #{deploy_to}/current/tmp/restart.txt"
	end
end

namespace :bundler do
  task :create_symlink, :roles => :app do
    shared_dir = File.join(shared_path, 'vendor_bundle')
    release_dir = File.join(current_release, 'vendor/bundle')
    run("mkdir -p #{shared_dir} && ln -s #{shared_dir} #{release_dir}")
  end
 
  task :bundle_new_release, :roles => :app do
    bundler.create_symlink
    run "cd #{release_path} && bundle install --deployment"
  end
end
