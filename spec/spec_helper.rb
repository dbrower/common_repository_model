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


class MiniTest::Unit::TestCase
  def assert_rels_ext(subject, predicate, objects = [])
    assert_equal objects.count, subject.relationships(predicate).count
    objects.each do |object|
      internal_uri = object.respond_to?(:internal_uri) ?
        object.internal_uri : object
      assert subject.relationships(predicate).include?(internal_uri)
    end
  end

  def assert_active_fedora_belongs_to(subject, method_name, object)
    subject.send(method_name).must_equal object
  end

  def assert_active_fedora_has_many(subject, method_name, objects)
    association = subject.send(method_name)
    assert_equal objects.count, association.count
    objects.each do |object|
      assert association.include?(object)
    end
  end
end
