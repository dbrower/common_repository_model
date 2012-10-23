lib = File.expand_path('../../../lib', __FILE__)
require 'minitest/autorun'
require File.join(lib,'common_repository_model/persistence_base')

describe CommonRepositoryModel::PersistenceBase do

  subject { CommonRepositoryModel::PersistenceBase.new }

  it 'should include ActiveFedora::Relationships' do
    subject.class.included_modules.must_include(ActiveFedora::Relationships)
  end

end