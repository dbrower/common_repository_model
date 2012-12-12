require_relative '../spec_helper'
require 'common_repository_model/area'
require 'common_repository_model/collection'

describe CommonRepositoryModel::Area do
  describe 'without persisting' do
    subject { FactoryGirl.build(:common_repository_model_area, name: name) }
    let(:name) { 'My Area Name'}

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

  describe 'fedora entries' do

    def build_expected_rels_ext_for_area(area)
      lines_of_text = []
      lines_of_text << %()
      lines_of_text << %(<rdf:RDF xmlns:ns0="info:fedora/fedora-system:def/model#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">)
      lines_of_text << %(  <rdf:Description rdf:about="#{area.internal_uri}">)
      lines_of_text << %(    <ns0:hasModel rdf:resource="info:fedora/afmodel:#{area.class.to_s.gsub('::','_')}"></ns0:hasModel>)
      lines_of_text << %(  </rdf:Description>)
      lines_of_text << %(</rdf:RDF>)
      lines_of_text.join("\n")
    end

    # Paranoid validation here as our RELS-EXT entry is critical
    it 'should have expected RELS-EXT entry' do
      @area = FactoryGirl.create(:common_repository_model_area)
      base_url = ActiveFedora.config.credentials[:url]
      object_url = File.join(base_url, 'objects', @area.pid)
      rels_ext_url = File.join(object_url, 'datastreams/RELS-EXT/content')
      response = RestClient.get(rels_ext_url)
      expected_body = build_expected_rels_ext_for_area(@area)

      assert_xml_equivalent(response.body, expected_body)
    end
  end

  describe 'integration (with persistence)' do
    let(:collection) { FactoryGirl.build(:common_repository_model_collection) }
    it 'should .find_by_name and .find_by_name!' do
      with_persisted_area(collection.name_of_area_to_assign) do |area|
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
      with_persisted_area(collection.name_of_area_to_assign) do |area|
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
