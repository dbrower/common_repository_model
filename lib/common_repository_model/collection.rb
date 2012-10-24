require_relative './persistence_base'
require_relative './area'

module CommonRepositoryModel
  class Collection < PersistenceBase

    belongs_to(
      :area,
      class_name:'CommonRepositoryModel::Area',
      property: :is_member_of_area
    )

    has_and_belongs_to_many(
      :child_collections,
      class_name: 'CommonRepositoryModel::Collection',
      property: :is_member_of,
      inverse_of: :has_membership_in
    )

    has_and_belongs_to_many(
      :parent_collections,
      class_name: 'CommonRepositoryModel::Collection',
      property: :has_membership_in,
      inverse_of: :is_member_of
    )

    has_metadata name: "properties", type: ActiveFedora::SimpleDatastream do |m|
      m.field :archive_identifier, :string
      m.field :archive_link, :string
      m.field :name, :string
    end

    delegate_to(
      :properties,
      [
        :archive_identifier,
        :archive_link,
        :name
      ],
      unique: true
    )
  end
end
