set :application, "app"

set :repository,  "git://github.com/blueboxjesse/demo_rails3_deploy_app.git"
set :scm, "git"
default_run_options[:pty] = true
set :checkout, 'export'

set :user, "deploy"

set :deploy_to, "/srv/#{application}"
set :use_sudo, false

set :server_name, ""
role :app, server_name
role :web, server_name
role :db,  server_name, :primary => true


namespace :deploy do
	task :restart do
		run "touch #{deploy_to}/current/tmp/restart.txt"
	end

	task :start do
		run "touch #{deploy_to}/current/tmp/restart.txt"
	end
end
