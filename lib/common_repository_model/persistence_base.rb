require 'active_fedora'
module CommonRepositoryModel
  class ObjectNotFoundError < ActiveFedora::ObjectNotFoundError
  end

  class PersistenceBase < ActiveFedora::Base
  end
end
