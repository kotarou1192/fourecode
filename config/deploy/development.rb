server 'dev.4ecode.com', user: 'rails', roles: %w[app db]

set :rails_env, 'production'
set :branch, 'develop'

set :deploy_to, "/var/www/html/fourecode-dev"
set :bundle_gemfile, -> { release_path.join('Gemfile') }

set :ssh_options, {
  user: "#{ENV['SERVER_USER'] || 'rails'}",
  keys: ["#{ENV['FOURECODE_PRODUCTION_SSH_KEY'] || '/Users/azufa/.ssh/ubuntu-rails'}"],
  auth_methods: %w('publickey')
}

# ==================
# puma
set :puma_daemonize, true
