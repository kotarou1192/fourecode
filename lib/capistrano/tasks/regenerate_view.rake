namespace :utils do
  desc 'Run a task on a remote server.'
  # run like: cap staging rake:invoke task=yoour:rake:take:name
  task :regenerate_view do
    on roles(:app) do
      execute "cd #{fetch :deploy_to} && #{fetch :rbenv_prefix} bundle exec rails db:drop_view"
      execute "cd #{fetch :deploy_to} && #{fetch :rbenv_prefix} bundle exec rails db:create_view"
    end
  end
end
