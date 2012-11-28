module CommonRepositoryModel
  module TestSupport
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

    def with_persisted_area(name = nil, &block)
      options = {}
      options[:name] = name if name
      area = nil
      area = CommonRepositoryModel::Area.find_by_name(name) if name
      area ||= FactoryGirl.create(:common_repository_model_area, options)
      if block.arity == 1
        block.call(area)
      else
        block.call
      end
    ensure
      area.delete if area
    end
  end
end
require 'factory_girl'
['collection','area','data'].each do |name|
  begin
    require_relative "../../spec/factories/common_repository_model/#{name}_factory"
  rescue FactoryGirl::DuplicateDefinitionError
  end
end
