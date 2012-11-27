module CommonRepositoryModel
  module TestSupport
  end
end
require 'factory_girl'
begin
  require_relative '../../spec/factories/common_repository_model/area_factory'
rescue FactoryGirl::DuplicateDefinitionError
end