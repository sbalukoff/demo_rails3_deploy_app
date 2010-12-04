# Capistrano Multistage Support
# Uncomment the following lines if you'd like Multistage Capistrano support.
# set :default_stage, "staging"
# set :stages, %w(production staging)
# require 'capistrano/ext/multistage'

# Include Bundler Extensions
# Comment out the following line if you're not using Bundler.
require "bundler/capistrano"

# RVM Settings
# Use either the latest RVM settings, or the legacy settings depending on your local RVM version.
$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require "rvm/capistrano"
set :rvm_ruby_string, "ree-1.8.7-2010.02"
set :rvm_type, :system
# set :default_environment, {
#  'PATH' => "/usr/local/rvm/gems/ree-1.8.7-2010.02/bin:/usr/local/rvm/bin:/bin:$PATH",
#  'RUBY_VERSION' => 'ree',
#  'GEM_HOME'     => '/usr/local/rvm/gems/ree-1.8.7-2010.02',
#  'GEM_PATH'     => '/usr/local/rvm/gems/ree-1.8.7-2010.02',
#}

# Application Settings
set :application, "APP NAME"
set :deploy_to, "/home/deploy/rails_apps/#{application}"

# Repo Settings
set :repository,  "git@github.com:/"
set :scm, "git"
set :checkout, 'export'

# General Settings
default_run_options[:pty] = true
set :keep_releases, 5

# Hooks
after "deploy", "deploy:cleanup"
after "deploy:update_code", "deploy:web:update_maintenance_page"
after "deploy:update_code", "deploy:secondary_symlink"

namespace :deploy do
  task :secondary_symlink, :except => { :no_release => true } do
    run "rm -f #{release_path}/config/database.yml"
    run "ln -s #{deploy_to}/shared/config/database.yml #{release_path}/config/database.yml"
  end

  task :restart, :except => { :no_release => true } do
    run "touch #{deploy_to}/current/tmp/restart.txt"
  end

  task :start, :except => { :no_release => true } do
    run "touch #{deploy_to}/current/tmp/restart.txt"
  end
end

# Disable the built in disable command and setup some intelligence so we can have images.
disable_path = "#{shared_path}/system/maintenance/"
namespace :deploy do
  namespace :web do
    desc "Disables the website by putting the maintenance files live."
    task :disable, :except => { :no_release => true } do
      on_rollback { run "mv #{disable_path}index.html #{disable_path}index.disabled.html" }
      run "mv #{disable_path}index.disabled.html #{disable_path}index.html"
    end

    desc "Enables the website by disabling the maintenance files."
    task :enable, :except => { :no_release => true } do
        run "mv #{disable_path}index.html #{disable_path}index.disabled.html"
    end

    desc "Copies your maintenance from public/maintenance to shared/system/maintenance."
    task :update_maintenance_page, :except => { :no_release => true } do
      run "rm -rf #{shared_path}/system/maintenance/; true"
      run "cp -r #{release_path}/public/maintenance #{shared_path}/system/"
    end
  end
end
