require_relative '../spec_helper'
require 'common_repository_model/collection'

describe CommonRepositoryModel::Collection do

  subject {
    CommonRepositoryModel::Collection.new(
      archive_identifier: archive_identifier,
      archive_link: archive_link,
      name: name
    )
  }
  let(:archive_identifier) { 'my archive identifier'}
  let(:archive_link) { 'my archive link' }
  let(:name) { 'my name' }

  it 'should have #name' do
    assert_equal name, subject.name
  end

  it 'should have #archive_link' do
    assert_equal archive_link, subject.archive_link
  end

  it 'should have #archive_identifier' do
    assert_equal archive_identifier, subject.archive_identifier
  end

  it 'should belong_to #area' do
    assert_respond_to subject, :area
    assert_respond_to subject, :area=
      assert_respond_to subject, :area_id
    assert_respond_to subject, :area_id=
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
