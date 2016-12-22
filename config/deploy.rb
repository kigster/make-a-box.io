# config valid only for Capistrano 3.1
# lock '3.1.0'

# Standard Flow:

# deploy
#   deploy:starting
#     [before]
#       deploy:ensure_stage
#       deploy:set_shared_assets
#     deploy:check
#   deploy:started
#   deploy:updating
#     git:create_release
#     deploy:symlink:shared
#   deploy:updated
#     [before]
#       deploy:bundle
#     [after]
#       deploy:migrate
#       deploy:compile_assets
#       deploy:normalize_assets
#   deploy:publishing
#     deploy:symlink:release
#   deploy:published
#   deploy:finishing
#     deploy:cleanup
#   deploy:finished
#     deploy:log_revision

require 'colored2'

set :application, 'makeabox'
set :repo_url, 'git@github.com:kigster/MakeABox.git'

set :bundle_flags, '--jobs=8 --deployment'
set :bundle_without, 'development test'
set :bundle_env_variables, { nokogiri_use_system_libraries: 1 }
# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

set :user_home, '/home/kig'
set :deploy_to, "#{fetch(:user_home)}/apps/makeabox"
set :rbenv, "#{fetch(:user_home)}/.rbenv/bin/rbenv"
set :native_gems, %i(nokogiri)

# Default value for :format is :pretty
set :format, :pretty
set :log_level, :info
set :pty, true

set :ssh_options, {
   keys: %w(/Users/kig/.ssh/id_rsa),
   forward_agent: false,
   auth_methods: %w(publickey)
}

set :linked_files, %w{config/secrets.yml}
set :linked_dirs, %w{bin log tmp/pdfs tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}
set :default_env, {}

# Default value for keep_releases is 5
set :keep_releases, 5

before 'deploy:starting', 'deploy:setup'
before 'bundler:install', 'ruby:bundler:native_config'

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'unicorn:stop'
      invoke 'unicorn:start'
    end
  end

  after :publishing, :restart
  after :restart, 'unicorn:restart'
  after :finished, 'os:unicorn:init'
end


