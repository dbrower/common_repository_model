require_relative '../spec_helper'
require 'common_repository_model/area'

describe CommonRepositoryModel::Area do

  subject { CommonRepositoryModel::Area.new(area_name: area_name) }
  let(:area_name) { 'My Area Name'}

  it 'should have #area_name' do
    assert_equal area_name, subject.area_name
  end

  it 'should have_many #collections' do
    subject.collections.must_be_kind_of(Array)
  end

end