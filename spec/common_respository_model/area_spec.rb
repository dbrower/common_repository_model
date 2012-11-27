require_relative '../spec_helper'
require 'common_repository_model/area'
require 'common_repository_model/collection'

describe CommonRepositoryModel::Area do
  describe 'without persisting' do
    subject { FactoryGirl.build(:area, name: name) }
    let(:name) { 'My Area Name'}

    it 'should serialize' do
      subject.as_json.fetch(:name).must_equal name
      subject.as_json.fetch(:pid).must_be_kind_of String
    end

    it 'should find or create by #name' do
      lambda { subject.save }.must_raise(NoMethodError)
      lambda { subject.save! }.must_raise(NoMethodError)
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

    it 'should build #collections' do
      subject.collections.build.
        must_be_kind_of(CommonRepositoryModel::Collection)
    end
  end

  describe 'integration (with persistence)' do
    let(:collection) { FactoryGirl.build(:collection, area: nil) }
    it 'should .find_by_name and .find_by_name!' do
      with_persisted_area do |area|
        CommonRepositoryModel::Area.find_by_name(area.name).must_equal area
        CommonRepositoryModel::Area.
          find_by_name("#{area.name}-tmp").must_equal nil

        CommonRepositoryModel::Area.find_by_name!(area.name).must_equal area
        lambda {
          CommonRepositoryModel::Area.find_by_name!("#{area.name}-tmp")
        }.must_raise(CommonRepositoryModel::ObjectNotFoundError)
      end
    end
    it 'should save' do
      with_persisted_area do |area|
        # Before we can add a collection, the containing object
        # must be saved
        area.collections << collection
        area.send(:save).must_equal true
        new_area = area.class.find(area.pid)
        new_area.collections.size.must_equal 1
      end
    end
  end
end
