require_relative './persistence_base'

module CommonRepositoryModel
  class Collection < PersistenceBase

    belongs_to :area, :class_name=>'CommonRepositoryModel::Area', :property=>:is_member_of_area
    # has_many :parts, :class_name=>'GenericData', :property=>:is_part_of
    # has_and_belongs_to_many :member_of, :class_name=>'GenericCollection', :property=>:is_member_of
    # has_many :members, :class_name=>'GenericData', :property=>:is_member_of

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