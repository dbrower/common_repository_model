require_relative '../spec_helper'
require 'common_repository_model/data_serializer'

describe CommonRepositoryModel::DataSerializer do
  subject { CommonRepositoryModel::DataSerializer.new(data) }
  let(:data) { FactoryGirl.build(:common_repository_model_data) }
  let(:json) { JSON.parse(subject.to_json) }
  let(:root) { json.fetch('data') }
  it 'should be JSON' do
    root.fetch('pid')
    root.fetch('slot_name').must_equal data.slot_name
    root.fetch('md5_checksum').must_equal data.md5_checksum
    root.fetch('collection').must_equal data.collection.pid
  end
end
