require_relative '../spec_helper'
require 'common_repository_model/file_datastream'

describe CommonRepositoryModel::FileDatastream do
  subject { CommonRepositoryModel::FileDatastream.new(nil, 'content') }
end
