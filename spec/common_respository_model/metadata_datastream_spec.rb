require_relative '../spec_helper'
require 'common_repository_model/metadata_datastream'

describe CommonRepositoryModel::MetadataDatastream do
  class MyMetadataStream < CommonRepositoryModel::MetadataDatastream
    register_vocabularies RDF::DC
    map_predicates do |map|
      map.title(:in => RDF::DC)
      map.created(:in => RDF::DC)
    end
  end
  class MyModel < CommonRepositoryModel::Collection
    has_metadata 'stuff', type: MyMetadataStream
  end

  let(:my_model) { MyModel.new }

  it 'should have #title' do
    FactoryGirl.create(
      :common_repository_model_area,
      name: my_model.name_of_area_to_assign
    )
    my_model.stuff.title = 'hello world'
    my_model.stuff.created = '2011-01-02'
    my_model.save!
    my_model.stuff.title.first.must_equal 'hello world'
    my_model.stuff.created.first.must_equal '2011-01-02'
  end
end
