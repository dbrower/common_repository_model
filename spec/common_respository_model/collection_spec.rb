require_relative '../spec_helper'
require 'common_repository_model/collection'

describe CommonRepositoryModel::Collection do

  subject { CommonRepositoryModel::Collection.new }

  it 'should belong_to #area' do
    subject.must_respond_to(:area)
    subject.must_respond_to(:area=)
    subject.must_respond_to(:area_id)
    subject.must_respond_to(:area_id=)
  end

  describe 'has_many #child_collections' do
    it 'should build #child_collections' do
      subject.child_collections.build.
        must_be_kind_of(CommonRepositoryModel::Collection)
    end
  end

  describe 'has_and_belongs_to_many #parent_collections' do
    it 'should be an Array' do
      subject.parent_collections.must_be_kind_of Array
    end
  end


  describe 'integration' do
    let(:child_collection) { CommonRepositoryModel::Collection.new }
    it 'should handle parent/child collection' do
      # Before we can add a collection, the containing object
      # must be saved
      subject.save.must_equal true
      subject.child_collections << child_collection
      subject.save.must_equal true
      new_subject = subject.class.find(subject.pid)

      new_subject.child_collections.size.must_equal 1

      new_subject.child_collections.first.
        parent_collections.first.must_equal new_subject
    end
  end

end
