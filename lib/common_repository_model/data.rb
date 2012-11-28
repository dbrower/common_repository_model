require_relative './persistence_base'
require_relative './collection'
require_relative './file_datastream'
require_relative './data_serializer'

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

  has_metadata name: "properties", type: ActiveFedora::SimpleDatastream do |m|
    m.field :slot_name, :string
    m.field :md5_checksum, :string
  end
  delegate_to :properties, [:slot_name, :md5_checksum], unique: true
  validates :slot_name, presence: true

  def content=(file)
    add_file_datastream(file, dsid: "content")
  end
end
