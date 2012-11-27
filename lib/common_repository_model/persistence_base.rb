require 'active_fedora'
module CommonRepositoryModel
  class ObjectNotFoundError < ActiveFedora::ObjectNotFoundError
  end

  class PersistenceBase < ActiveFedora::Base
    class_attribute :attributes_for_json
    self.attributes_for_json = []

    def self.register_attribute(attribute_name, options = {})
      delegate(attribute_name, options)
      self.attributes_for_json ||= []
      self.attributes_for_json += [attribute_name]
    end
    def as_json(*args)
      self.class.attributes_for_json.
      each_with_object(base_json_attributes) {|value, memo|
        memo[value] = public_send(value)
        memo
      }
    end
    protected
    def base_json_attributes
      { pid: pid }
    end
  end
end
