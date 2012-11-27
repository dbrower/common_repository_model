# This is a spec that should not include the spec_helper. It is to be used by
# other applications.
require 'minitest/autorun'
require_relative '../../lib/common_repository_model/test_support'

describe CommonRepositoryModel::TestSupport do
  describe 'area' do
    subject { FactoryGirl.build(:common_repository_model_area) }
    it { subject.must_be_instance_of CommonRepositoryModel::Area }
    it { subject.valid?.must_equal true }
  end
end
