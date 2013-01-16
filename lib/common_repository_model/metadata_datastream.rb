require 'active_fedora'
require_relative './custom_vocabulary'

module CommonRepositoryModel

  class MetadataDatastream < ActiveFedora::NtriplesRDFDatastream
  end
end
