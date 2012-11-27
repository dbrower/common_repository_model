require 'common_repository_model/area'
require 'common_repository_model/collection'
require 'common_repository_model/data'

FactoryGirl.define do
  factory :collection, class: CommonRepositoryModel::Collection do
    area { CommonRepositoryModel::Area.all.first }
  end
  factory :data, class: CommonRepositoryModel::Data do
    sequence(:slot_name) { |n| "Slot Name #{n}" }
    sequence(:md5_checksum) { |n| "#{n}abc"}
  end
end