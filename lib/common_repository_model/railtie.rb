module CommonRepositoryModel
  class Railtie < Rails::Railtie
    rake_tasks do
      load "tasks/common_repository_model.tasks"
    end
  end
end