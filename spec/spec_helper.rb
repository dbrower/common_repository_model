$:.unshift File.expand_path('../../lib', __FILE__)
require 'minitest/autorun'
require 'active_fedora'
require 'factory_girl'
FactoryGirl.find_definitions
ActiveFedora.init(
  fedora_config_path: File.join(File.dirname(__FILE__),"config/fedora.yml"),
  solr_config_path: File.join(File.dirname(__FILE__),"config/solr.yml"),
  environment: :test
)

require 'common_repository_model/test_support'
class MiniTest::Unit::TestCase
  include CommonRepositoryModel::TestSupport
end
