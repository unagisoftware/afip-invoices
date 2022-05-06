set :stages, %w(production staging)
set :default_stage, 'staging'

puts ENV['REPO_URL']

set :repo_url, ENV['REPO_URL']
set :application, ENV['APPLICATION_NAME']
set :user, ENV['SERVER_USER']
set :puma_threads, [4, 16]
set :puma_workers, 0
set :pty, true
set :use_sudo, false
set :deploy_via, :remote_cache
set :deploy_to, ENV['SERVER_APPLICATION_DIRECTORY']
set :puma_systemctl_user, :user
set :puma_bind, "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state, "#{shared_path}/tmp/pids/puma.state"
set :puma_pid, "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.error.log"
set :puma_error_log, "#{release_path}/log/puma.access.log"
set :ssh_options, { forward_agent: true, user: fetch(:user) }
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :pg_system_user, ENV['SERVER_PG_SYSTEM_USER']
set :pg_system_db, ENV['SERVER_PG_SYSTEM_DB']
set :puma_init_active_record, true

set :rbenv_ruby, '2.7.6'

set :branch, ENV['BRANCH'] if ENV['BRANCH']
set :keep_releases, 5

## Linked Files & Directories (Default None):
set :linked_files, %w{config/application.yml}
set :linked_dirs, %w{log public/uploads}

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end
  before :start, :make_dirs
end

namespace :deploy do
  desc "Make sure local git is in sync with remote."
  task :check_revision do
    on roles(:app) do
      unless `git rev-parse HEAD` == `git rev-parse origin/#{fetch(:branch)}`
        puts "WARNING: HEAD is not the same as origin/#{fetch(:branch)}"
        puts "Run `git push` to sync changes."
        exit
      end
    end
  end

  desc 'Creates database'
  task :create_database do
    on roles(:app), primary: true do |host|
      if database_exists?
        puts 'The database already exists. Skipping creation'
      else
        puts 'Database does not exist. Creating DB'
        rails_env = fetch(:stage)
        within release_path do
          with rails_env: fetch(:rails_env) do
            execute :rake, "db:create RAILS_ENV=#{rails_env}"
          end
        end
      end
    end
  end

  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      execute %[mkdir -p "#{deploy_to}"]

      execute %[mkdir -p "#{shared_path}/config"]
      execute %[chmod g+rx,u+rwx "#{shared_path}/config"]

      execute %[touch "#{shared_path}/config/application.yml"]
      execute %[echo "-----> Be sure to edit '#{shared_path}/config/application.yml'"]
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'puma:restart'
    end
  end

  before :starting, :check_revision
  before :updated, :create_database

  after :finishing, :cleanup
  after :finishing, :restart

  def database_exists?
    db_file = capture "cat #{release_path}/config/database.yml"
    st = YAML.load(db_file)[fetch(:stage).to_s]
    cmd = "psql -U #{fetch(:pg_system_user)} -d #{fetch(:pg_system_db)} -tAc \"SELECT 1 FROM pg_database WHERE datname='#{st['database']}';\" | grep -q 1"
    test *cmd
  end
end

namespace :rails do
  desc "Open the rails console on each of the remote servers"
  task :console do
    on roles(:app), primary: true do |host|
      rails_env = fetch(:stage)
      execute_interactively "#{ENV['SERVER_RBENV_BIN_PATH']} exec bundle exec rails console -e #{rails_env}"
    end
  end

  task :logs do
    on roles(:app), primary: true do |host|
      rails_env = fetch(:stage)
      execute_interactively "tail -f log/#{rails_env}.log"
    end
  end

  def execute_interactively(command)
    user = fetch(:user)
    port = fetch(:port) || 22
    exec "ssh -l #{user} #{host} -p #{port} -t 'cd #{deploy_to}/current && #{command}'"
  end
end
