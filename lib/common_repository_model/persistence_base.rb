require 'active_fedora'
module CommonRepositoryModel
  class PersistenceBase < ActiveFedora::Base
    include ActiveFedora::Relationships
  end
end
