require_relative '../../../lib/common_repository_model/data'

FactoryGirl.define do
  factory :common_repository_model_data, class: CommonRepositoryModel::Data do
    collection { FactoryGirl.build(:common_repository_model_collection) }
    sequence(:slot_name) { |n| "Slot Name #{n}" }
    sequence(:md5_checksum) { |n| "#{n}abc"}
  end
end

