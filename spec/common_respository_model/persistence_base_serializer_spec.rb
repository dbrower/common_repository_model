require_relative '../spec_helper'
require 'common_repository_model/persistence_base_serializer'

describe CommonRepositoryModel::PersistenceBaseSerializer do
  subject { CommonRepositoryModel::PersistenceBaseSerializer.new(base) }
  let(:base) { CommonRepositoryModel::PersistenceBase.new }
  let(:json) { JSON.parse(subject.to_json) }
  let(:root) { json.fetch('persistence_base') }
  it 'should be JSON with a PID' do
    root.fetch('pid')
  end
end