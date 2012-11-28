require_relative '../spec_helper'
require 'common_repository_model/area_serializer'

describe CommonRepositoryModel::AreaSerializer do
  subject { CommonRepositoryModel::AreaSerializer.new(area) }
  let(:area) { CommonRepositoryModel::Area.new(name: 'hello') }
  let(:json) { JSON.parse(subject.to_json) }
  let(:root) { json.fetch('area') }
  it 'should be JSON' do
    root.fetch('pid')
    root.fetch('name').must_equal area.name
  end
end