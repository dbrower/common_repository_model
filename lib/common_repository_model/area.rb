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
      m.field 'name', :string
    end

    validates :name, presence: true

    delegate_to 'properties', [:name], unique: true

    # We shouldn't be calling these
    protected :save, :save!
  end
end