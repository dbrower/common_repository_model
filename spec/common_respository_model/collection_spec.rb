lib = File.expand_path('../../../lib', __FILE__)
require 'minitest/autorun'
require File.join(lib,'common_repository_model/collection')

describe CommonRepositoryModel::Collection do

  subject {
    CommonRepositoryModel::Collection.new(
      archive_identifier: archive_identifier,
      archive_link: archive_link,
      collection: collection
    )
  }
  let(:archive_identifier) { 'my archive identifier'}
  let(:archive_link) { 'my archive link' }
  let(:collection) { 'my collection' }

  it 'should have #collection' do
    assert_equal collection, subject.collection
  end

  it 'should have #archive_link' do
    assert_equal archive_link, subject.archive_link
  end

  it 'should have #archive_identifier' do
    assert_equal archive_identifier, subject.archive_identifier
  end

end
