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

    def self.find_by_name(name)
      find({name_s: name}).first
    end

    def self.find_by_name!(name)
      find({name_s: name.to_s}).first ||
      raise(
        CommonRepositoryModel::ObjectNotFoundError.new(
          "#{self} with name: #{name.to_s} not found"
        )
      )
    end

    # We shouldn't be calling these
    protected :save, :save!
  end
end
