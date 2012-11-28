require_relative '../../../lib/common_repository_model/data'

FactoryGirl.define do
  factory :common_repository_model_collection, class: CommonRepositoryModel::Collection do
    area { CommonRepositoryModel::Area.all.first }
  end
end