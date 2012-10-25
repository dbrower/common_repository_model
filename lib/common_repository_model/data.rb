require_relative './persistence_base'
require_relative './collection'

class CommonRepositoryModel::Data < CommonRepositoryModel::PersistenceBase

  belongs_to(
    :collection,
    class_name: 'CommonRepositoryModel::Collection',
    property: :is_part_of
  )

end
