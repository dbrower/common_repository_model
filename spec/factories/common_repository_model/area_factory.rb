require_relative '../../../lib/common_repository_model/area'

FactoryGirl.define do
  factory :common_repository_model_area, class: CommonRepositoryModel::Area do
    sequence(:name) { |n| "Area-#{n}" }
  end
end