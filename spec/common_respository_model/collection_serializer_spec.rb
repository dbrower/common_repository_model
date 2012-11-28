require_relative '../spec_helper'
require 'common_repository_model/collection_serializer'

describe CommonRepositoryModel::CollectionSerializer do
  subject { CommonRepositoryModel::CollectionSerializer.new(collection) }
  let(:collection) {
    FactoryGirl.build(:common_repository_model_collection)
  }
  let(:json) { JSON.parse(subject.to_json) }
  let(:root) { json.fetch('collection') }
  it 'should be JSON' do
    with_persisted_area(collection.name_of_area_to_assign) do
      root.fetch('pid')
      root.fetch('area').must_equal collection.area.pid
    end
  end
end
