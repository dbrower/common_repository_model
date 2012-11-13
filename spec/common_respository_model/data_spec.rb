require_relative '../spec_helper'
require 'common_repository_model/data'

describe CommonRepositoryModel::Data do

  subject { CommonRepositoryModel::Data.new(slot_name: '1234') }

  describe 'integration' do
    let(:collection) { CommonRepositoryModel::Collection.new }
    let(:file_1) { File.new(__FILE__) }
    let(:file_2) {
      File.new(File.join(File.dirname(__FILE__), '../spec_helper.rb'))
    }

    it 'should have #slot_name' do
      subject.must_respond_to :slot_name
      subject.must_respond_to :slot_name=
    end

    it 'should have content versions' do
      subject.content = file_1
      subject.save
      subject.content.content.must_equal file_1.read
      subject.content = file_2
      subject.save
      subject.content.content.must_equal file_2.read
      subject.content.versions.count.must_equal 2
    end

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
