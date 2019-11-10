set :ruby_version, '2.6.5'
set :target_os, 'linux'
set :rails_env, 'production'

require_relative '../../tools/capistrano/loader/os'

server 'makeabox.io', roles: %w{app db web worker}, user: 'kig', sudo: true
set :gem_config, {}

