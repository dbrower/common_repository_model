require_relative './persistence_base'
require_relative './collection'
require_relative './file_datastream'

class CommonRepositoryModel::Data < CommonRepositoryModel::PersistenceBase
  belongs_to(
    :collection,
    class_name: 'CommonRepositoryModel::Collection',
    property: :is_part_of
  )

  has_file_datastream(
    name: "content",
    type: CommonRepositoryModel::FileDatastream
  )

  def content=(file)
    add_file_datastream(file, dsid: "content")
  end
end
