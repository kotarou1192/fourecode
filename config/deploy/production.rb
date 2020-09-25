# server-based syntax
# ======================
# Defines a single server with a list of roles and multiple properties.
# You can define all roles on a single server, or split them:

# server "example.com", user: "deploy", roles: %w{app db web}, my_property: :my_value
# server "example.com", user: "deploy", roles: %w{app web}, other_property: :other_value
# server "db.example.com", user: "deploy", roles: %w{db}
server '4ecode.com', user: 'rails', roles: %w[app db]
# server 'ls-8837dc160830cb173282460d26b0eb313e7e2ff4.cbprlpeszvir.ap-northeast-1.rds.amazonaws.com', user: 'dbmasteruser', roles: %w[db]

set :rails_env, 'production'

# role-based syntax
# ==================

# Defines a role with one or multiple servers. The primary server in each
# group is considered to be the first unless any hosts have the primary
# property set. Specify the username and a domain or IP for the server.
# Don't use `:all`, it's a meta role.

# role :app, %w{deploy@example.com}, my_property: :my_value
# role :web, %w{user1@primary.com user2@additional.com}, other_property: :other_value
# role :db,  %w{deploy@example.com}


# Configuration
# =============
# You can set any configuration variable like in config/deploy.rb
# These variables are then only loaded and set in this stage.
# For available Capistrano configuration variables see the documentation page.
# http://capistranorb.com/documentation/getting-started/configuration/
# Feel free to add new variables to customise your setup.


# Custom SSH Options
# ==================
# You may pass any option but keep in mind that net/ssh understands a
# limited set of options, consult the Net::SSH documentation.
# http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start
#
# Global options
# --------------
#  set :ssh_options, {
#    keys: %w(/home/user_name/.ssh/id_rsa),
#    forward_agent: false,
#    auth_methods: %w(password)
#  }
#
set :ssh_options, {
  user: "#{ENV['SERVER_USER']}",
  keys: ["#{ENV['FOURECODE_PRODUCTION_SSH_KEY']}"],
  auth_methods: %w('publickey')
}
# The server-based syntax can be used to override options:
# ------------------------------------
# server "example.com",
#   user: "user_name",
#   roles: %w{web app},
#   ssh_options: {
#     user: "user_name", # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: "please use keys"
#   }

# ==================
# puma
set :puma_daemonize, true

# ==================
# nginx
set :nginx_config_name, "#{fetch(:application)}"
set :nginx_server_name, "localhost #{fetch(:nginx_config_name)}"
set :nginx_use_ssl, true
set :nginx_ssl_certificate, "/etc/letsencrypt/live/#{fetch(:nginx_config_name)}/fullchain.pem"
set :nginx_ssl_certificate_key, "/etc/letsencrypt/live/#{fetch(:nginx_config_name)}/privkey.pem"
