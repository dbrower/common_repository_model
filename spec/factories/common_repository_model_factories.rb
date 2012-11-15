require 'common_repository_model/area'
require 'common_repository_model/collection'
require 'common_repository_model/data'

FactoryGirl.define do
  factory :area, class: CommonRepositoryModel::Area do
    sequence(:name) { |n| "Area #{n}" }
    to_create { |instance| instance.send(:save!) }
  end
  factory :collection, class: CommonRepositoryModel::Collection do
    area { CommonRepositoryModel::Area.all.first }
  end
  factory :data, class: CommonRepositoryModel::Data do
  end
end