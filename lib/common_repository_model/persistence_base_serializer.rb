require 'active_model/serializer'
module CommonRepositoryModel
  class PersistenceBaseSerializer < ActiveModel::Serializer
    attribute :pid
  end
end