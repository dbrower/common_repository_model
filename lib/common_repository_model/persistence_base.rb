require 'active_fedora'
require 'active_model_serializers'
require_relative './persistence_base_serializer'
module CommonRepositoryModel
  class ObjectNotFoundError < ActiveFedora::ObjectNotFoundError
  end

  class PersistenceBase < ActiveFedora::Base
    include ActiveModel::SerializerSupport
    def active_model_serializer
      "#{self.class}Serializer".constantize
    end

    class_attribute :attributes_for_json
    self.attributes_for_json = []

    def self.register_attribute(attribute_name, options = {})
      delegate(attribute_name, options)
      self.attributes_for_json ||= []
      self.attributes_for_json += [attribute_name]
    end

  end
end
