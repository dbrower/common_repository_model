require 'rails/generators'
class CommonRepositoryModel::Collection < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)

  def create_collection
    template(
      'collection.rb.erb',
      File.join('app/repository_models/', "#{file_name}.rb")
    )
  end
  def create_service_spec
    template(
      'collection_spec.rb.erb',
      File.join('spec/repository_models/', "#{file_name}_spec.rb")
    )
  end
end
