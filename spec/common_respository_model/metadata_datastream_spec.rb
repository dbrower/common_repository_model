require_relative '../spec_helper'
require 'common_repository_model/metadata_datastream'

describe CommonRepositoryModel::MetadataDatastream do
  describe 'class methods' do
    class MockNode
      def initialize(text)
        @text = text
      end
      def text; @text; end
    end
    subject { CommonRepositoryModel::MetadataDatastream }
    it 'has .not_available_date' do
      subject.not_available_date.must_be_kind_of Date
    end
    it 'has .text_accessor lambda' do
      node = MockNode.new('  Hello World  ')
      subject.text_accessor.call(node).must_equal 'Hello World'
    end
    it 'has .date_accessor lambda that handles empty values' do
      node = MockNode.new('')
      subject.date_accessor.call(node).must_equal subject.not_available_date
    end
    it 'has .date_accessor lambda that handles date parsable values' do
      node = MockNode.new('2011-11-12')
      subject.date_accessor.call(node).must_equal Date.new(2011,11,12)
    end
  end
end
