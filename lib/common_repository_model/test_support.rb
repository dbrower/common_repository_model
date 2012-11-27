module CommonRepositoryModel
  module TestSupport
    def with_persisted_area(name = nil)
      options = {}
      options[:name] = name if name
      area = FactoryGirl.create(:common_repository_model_area, options)
      yield(area)
    ensure
      area.delete if area
    end
  end
end
require 'factory_girl'
begin
  require_relative '../../spec/factories/common_repository_model/area_factory'
rescue FactoryGirl::DuplicateDefinitionError
end
