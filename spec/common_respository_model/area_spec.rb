require_relative '../spec_helper'
require 'common_repository_model/area'
require 'common_repository_model/collection'

describe CommonRepositoryModel::Area do

  subject { CommonRepositoryModel::Area.new(name: name) }
  let(:name) { 'My Area Name'}

  it 'should find or create by #name' do
    area = CommonRepositoryModel::Area.new(name: name)
    lambda { area.save }.must_raise(NoMethodError)
    lambda { area.save! }.must_raise(NoMethodError)
  end

  it 'should require a #name' do
    subject.name = nil
    subject.valid?.must_equal false
    subject.name = name
    subject.valid?.must_equal true
  end

  it 'should have #name' do
    subject.name.must_equal name
  end

  describe 'has_many #collections' do
    it 'should build #collections' do
      subject.collections.build.
        must_be_kind_of(CommonRepositoryModel::Collection)
    end
  end

  describe 'integration' do
    let(:collection) { CommonRepositoryModel::Collection.new }
    it 'should save' do
      # Before we can add a collection, the containing object
      # must be saved
      subject.send(:save).must_equal true
      subject.collections << collection
      subject.send(:save).must_equal true
      new_subject = subject.class.find(subject.pid)

      new_subject.collections.size.must_equal 1
    end
  end
end
