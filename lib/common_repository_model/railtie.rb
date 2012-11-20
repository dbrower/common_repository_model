module CommonRepositoryModel
  class Railtie < Rails::Railtie
    rake_tasks do
      load "tasks/common_repository_model.tasks"
    end
    generators do
      require(
        'generators/common_repository_model/collection/collection_generator'
      )
    end
  end
end
