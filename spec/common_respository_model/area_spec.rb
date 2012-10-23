lib = File.expand_path('../../../lib', __FILE__)
require 'minitest/autorun'
require File.join(lib,'common_repository_model/area')

describe CommonRepositoryModel::Area do

  subject { CommonRepositoryModel::Area.new(area_name: area_name) }
  let(:area_name) { 'My Area Name'}

  it 'should have #area_name' do
    assert_equal area_name, subject.area_name
  end

end