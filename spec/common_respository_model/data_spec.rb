require_relative '../spec_helper'
require 'common_repository_model/data'

describe CommonRepositoryModel::Data do

  subject { CommonRepositoryModel::Data.new }

  describe 'integration' do
    let(:collection) { CommonRepositoryModel::Collection.new }
    it 'should save' do
      # Before we can add a collection, the containing object
      # must be saved
      collection.save
      subject.collection = collection
      subject.save

      @subject = subject.class.find(subject.pid)

      assert_rels_ext(@subject, :is_part_of, [collection])
      assert_active_fedora_belongs_to(@subject, :collection, collection)
    end
  end
end
