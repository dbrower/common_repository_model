require_relative '../spec_helper'
require 'common_repository_model/collection'

describe CommonRepositoryModel::Collection do
  subject { FactoryGirl.build(:collection) }
  it 'should require an area' do
    with_persisted_area do |area|
      subject.area = area
      subject.area.must_be_kind_of(CommonRepositoryModel::Area)
      subject.valid?.must_equal true
      subject.area = nil
      subject.valid?.must_equal false
    end
  end

  describe '#find_or_build_data_for_given_slot_names' do
    it 'yields an existing data node if the slot name exists' do
      slot_name = 'AnotherThing'
      initial_object = subject.data.build(slot_name: slot_name)
      object = subject.find_or_build_data_for_given_slot_names([slot_name]).first
      object.must_equal initial_object
    end
    it 'yields a newly built data node if the slot name does not exist' do
      slot_name = 'Chicken'
      object = subject.find_or_build_data_for_given_slot_names([slot_name]).first
      object.slot_name.must_equal slot_name
      object.persisted?.must_equal false
    end
  end

  it 'has many data' do
    subject.data.build.must_be_kind_of(CommonRepositoryModel::Data)
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
    after(:each) do
      begin
        subject.area.delete if subject.area.persisted?
      rescue
      end
    end
    let(:child_collection) { FactoryGirl.build(:collection) }
    it 'should handle parent/child collection' do
      # Before we can add a collection, the containing object
      # must be saved
      with_persisted_area do |area|
        subject.area = area
        subject.save.must_equal true
        subject.child_collections << child_collection
        subject.save.must_equal true
        @collection = subject.class.find(subject.pid)
        @child_collection = child_collection.class.find(child_collection.pid)

        # We shouldn't store any child relations
        assert_rels_ext(@collection, :has_members, [])
        assert_active_fedora_has_many(
          @collection, :child_collections, [@child_collection]
        )

        assert_rels_ext(@child_collection, :is_member_of, [@collection])
        assert_active_fedora_has_many(
          @child_collection, :parent_collections, [@collection]
        )
      end
    end
  end

end
