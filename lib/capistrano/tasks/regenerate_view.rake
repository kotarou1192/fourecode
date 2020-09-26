namespace :utils do
  desc 'Run a task on a remote server.'
  # run like: cap staging rake:invoke task=yoour:rake:take:name
  task :regenerate_view do
    on roles(:app) do
      execute "cd #{current_path} && #{fetch :rbenv_prefix} bundle exec rails db:drop_view"
      execute "cd #{current_path} && #{fetch :rbenv_prefix} bundle exec rails db:create_view"
    end
  end

  task :create_view do
    on roles(:app) do
      execute "cd #{current_path} && #{fetch :rbenv_prefix} bundle exec rails db:create_view"
    end
  end

  task :drop_view do
    on roles(:app) do
      execute "cd #{current_path} && #{fetch :rbenv_prefix} bundle exec rails db:drop_view"
    end
  end
end
