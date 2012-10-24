require_relative './persistence_base'
require_relative './collection'
module CommonRepositoryModel
  class Area < PersistenceBase

    has_many(
      :collections,
      class_name: 'CommonRepositoryModel::Collection',
      property: :is_member_of_area
    )

    has_metadata(name: "properties",type: ActiveFedora::SimpleDatastream) do |m|
      m.field 'area_name', :string
    end

    delegate_to 'properties', [:area_name], unique: true
  end
end