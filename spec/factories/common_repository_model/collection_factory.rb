require_relative '../../../lib/common_repository_model/data'

FactoryGirl.define do
  factory :common_repository_model_collection, class: CommonRepositoryModel::Collection do
    before(:create) { |collection|
      area_name = collection.name_of_area_to_assign
      CommonRepositoryModel::Area.find_by_name(area_name) ||
      FactoryGirl.create(:common_repository_model_area, name: area_name)
    }
  end
end
