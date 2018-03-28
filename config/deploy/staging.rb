server ENV['STAGING_SERVER_SSH_NAME'], port: 22, roles: [:web, :app, :db]

set :rails_env, 'staging'
set :stage, :staging

if ENV['BRANCH']
  set :branch, ENV['BRANCH'] if ENV['BRANCH']
else
  set :branch, 'main'
end
