require_relative '../spec_helper'
require 'common_repository_model/persistence_base'

describe CommonRepositoryModel::PersistenceBase do

  subject { CommonRepositoryModel::PersistenceBase.new }

  it 'should gracefully handle as_json' do
    subject.as_json.fetch(:pid)
  end

end