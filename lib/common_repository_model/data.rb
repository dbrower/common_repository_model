require_relative './persistence_base'
require_relative './collection'

class CommonRepositoryModel::Data < CommonRepositoryModel::PersistenceBase

  belongs_to(
    :collection,
    class_name: 'CommonRepositoryModel::Collection',
    property: :is_part_of
  )

  has_file_datastream(
    name: "content",
    prefix: "CONTENT",
    type: ActiveFedora::Datastream,
    controlGroup: 'M'
  )

end
