require 'active_fedora'
require 'active_model_serializers'
require_relative './persistence_base_serializer'
require_relative './exceptions'
module CommonRepositoryModel
  class PersistenceBase < ActiveFedora::Base
    include ActiveModel::SerializerSupport
    def active_model_serializer
      "#{self.class}Serializer".constantize
    end

    def self.find(*args,&block)
      super
    rescue RSolr::Error::Http => e
      raise CommonRepositoryModel::ObjectNotFoundError.new(
        "#{self}.find(#{args.inspect}) had a SOLR error.", e
      )
    rescue ArgumentError, ActiveFedora::ObjectNotFoundError => e
      raise CommonRepositoryModel::ObjectNotFoundError.new(e.message, e)
    end
  end
end
