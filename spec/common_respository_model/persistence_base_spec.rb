require_relative '../spec_helper'
require 'common_repository_model/persistence_base'

describe CommonRepositoryModel::PersistenceBase do

  subject { CommonRepositoryModel::PersistenceBase.new }

  describe '.find' do
    it 'should handle find with missing parameter' do
      lambda {
        subject.class.find(nil)
      }.must_raise(CommonRepositoryModel::ObjectNotFoundError)
    end

    it 'should handle find with invalid PID' do
      lambda {
        subject.class.find('-1')
      }.must_raise(CommonRepositoryModel::ObjectNotFoundError)
    end
  end
end