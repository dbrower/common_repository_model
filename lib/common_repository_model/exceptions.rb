require 'active_fedora'
module CommonRepositoryModel
  class ObjectNotFoundError < ActiveFedora::ObjectNotFoundError
    attr_reader :original_exception
    def initialize(message, original_exception = nil)
      super(message)
      @original_exception = original_exception || self
    end
  end
end