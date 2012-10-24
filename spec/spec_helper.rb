$:.unshift File.expand_path('../../lib', __FILE__)
require 'minitest/autorun'
require 'active_fedora'
ActiveFedora.init(
  fedora_config_path: File.join(File.dirname(__FILE__),"config/fedora.yml"),
  solr_config_path: File.join(File.dirname(__FILE__),"config/solr.yml"),
  environment: :test
)
