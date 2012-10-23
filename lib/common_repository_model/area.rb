require_relative './persistence_base'
module CommonRepositoryModel
  class Area < PersistenceBase

    has_metadata(name: "properties",type: ActiveFedora::SimpleDatastream) do |m|
      m.field 'area_name', :string
    end

    delegate_to 'properties', [:area_name], unique: true
  end
end