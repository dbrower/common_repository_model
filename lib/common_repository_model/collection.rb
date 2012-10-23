require_relative './persistence_base'

module CommonRepositoryModel
  class Collection < PersistenceBase

    has_metadata name: "properties", type: ActiveFedora::SimpleDatastream do |m|
      m.field :archive_identifier, :string
      m.field :archive_link, :string
      m.field :collection, :string
    end
    delegate_to(
      :properties,
      [
        :archive_identifier,
        :archive_link,
        :collection
      ],
      unique: true
    )
  end
end
