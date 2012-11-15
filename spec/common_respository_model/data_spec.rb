require_relative '../spec_helper'
require 'common_repository_model/data'

describe CommonRepositoryModel::Data do
  subject { FactoryGirl.build(:data) }

  describe 'integration' do
    let(:collection) { FactoryGirl.build(:collection) }
    let(:file_1) { File.new(__FILE__) }
    let(:file_2) {
      File.new(File.join(File.dirname(__FILE__), '../spec_helper.rb'))
    }

    it 'should have #slot_name' do
      subject.must_respond_to :slot_name
      subject.must_respond_to :slot_name=
        end

    it 'should have #md5_checksum' do
      subject.must_respond_to :md5_checksum
      subject.must_respond_to :md5_checksum=
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
      with_persisted_area do |area|
        collection.area = area
        # Before we can add a collection, the containing object
        # must be saved
        collection.save!
        subject.collection = collection
        subject.save!

        @subject = subject.class.find(subject.pid)

        assert_rels_ext(@subject, :is_part_of, [collection])
        assert_active_fedora_belongs_to(@subject, :collection, collection)

      end
    end
  end
end
