require 'rake'

namespace :deploy do
  desc 'deploy to server'
  task 'upload' do
    sh 'bundle exec cap production deploy'
  end
end
