require_relative './persistence_base_serializer'
class CommonRepositoryModel::DataSerializer < CommonRepositoryModel::PersistenceBaseSerializer
  attributes :slot_name, :md5_checksum
  has_one :collection, embed: :ids
end