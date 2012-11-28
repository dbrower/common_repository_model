require_relative './persistence_base_serializer'
class CommonRepositoryModel::CollectionSerializer < CommonRepositoryModel::PersistenceBaseSerializer
  has_one :area, embed: :ids
end
