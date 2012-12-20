require 'rails/generators'

class CommonRepositoryModel::CollectionGenerator < Rails::Generators::NamedBase
  check_class_collision
  source_root File.expand_path('../templates', __FILE__)
  class_option :test_dir, :type => :string, :default => "spec/factories", :desc => "The directory where the factories should go"
  argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"

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

  def create_fixture_file
    template 'collection_factory.rb.erb', File.join(options[:test_dir], "#{file_name}_factory.rb")
  end

  def create_serializer
    template(
      'collection_serializer.rb.erb',
      File.join('app/repository_serializers/', "#{file_name}_serializer.rb")
    )
  end

  def create_serializer_spec
    template(
      'collection_serializer_spec.rb.erb',
      File.join('spec/repository_serializers/', "#{file_name}_serializer_spec.rb")
    )
  end

end
