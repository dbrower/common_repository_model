require_relative '../spec_helper'
require 'common_repository_model/collection'
require 'equivalent-xml'

describe CommonRepositoryModel::Collection do
  subject { FactoryGirl.build(:common_repository_model_collection) }

  it 'should have an #area_name' do
    subject.respond_to?(:area_name)
  end

  it 'should have an #name_of_area_to_assign' do
    subject.respond_to?(:name_of_area_to_assign)
  end

  it 'should require an area' do
    subject.valid?.must_equal false
    subject.errors[:area].size.wont_equal 0
    with_persisted_area(subject.name_of_area_to_assign) do |area|
      subject.area.must_equal area
      subject.valid?.must_equal true
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

  describe 'fedora entries' do
    let(:collection) {
      FactoryGirl.build(:common_repository_model_collection)
    }

    def build_expected_rels_ext_for_collection(collection)
      lines_of_text = []
      lines_of_text << %()
      lines_of_text << %(<rdf:RDF xmlns:ns0="info:common_repository_model#" xmlns:ns1="info:fedora/fedora-system:def/model#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">)
      lines_of_text << %(<rdf:Description rdf:about="#{collection.internal_uri}">)
      lines_of_text << %(<ns0:isMemberOfArea rdf:resource="#{collection.area.internal_uri}"></ns0:isMemberOfArea>)
      lines_of_text << %(<ns1:hasModel rdf:resource="info:fedora/afmodel:#{collection.class.to_s.gsub('::','_')}"></ns1:hasModel>)
      lines_of_text << %(</rdf:Description>)
      lines_of_text << %(</rdf:RDF>)
      lines_of_text.join("\n")
    end

    # Paranoid validation here as our RELS-EXT entry is critical
    it 'should have expected RELS-EXT entry' do
      with_persisted_area(collection.name_of_area_to_assign) do
        collection.save!
        base_url = ActiveFedora.config.credentials[:url]
        object_url = File.join(base_url, 'objects', collection.pid)
        rels_ext_url = File.join(object_url, 'datastreams/RELS-EXT/content')
        response = RestClient.get(rels_ext_url)

        expected = build_expected_rels_ext_for_collection(collection)

        assert_xml_equivalent(response.body, expected)
      end
    end
  end

  describe 'integration' do
    let(:child_collection) {
      FactoryGirl.build(:common_repository_model_collection)
    }
    it 'should keep a child collection in the parent collection' do
      with_persisted_area(subject.name_of_area_to_assign) do
        subject.save!
        child_collection.parent_collections += [subject]
        child_collection.area.must_equal subject.area
      end
    end
    it 'should handle parent/child collection' do
      # Before we can add a collection, the containing object
      # must be saved
      with_persisted_area(subject.name_of_area_to_assign) do
        subject.save!
        subject.child_collections << child_collection
        subject.save!

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
