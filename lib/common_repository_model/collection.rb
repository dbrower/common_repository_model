require_relative './persistence_base'
require_relative './area'
require_relative './data'
require 'set'

module CommonRepositoryModel
  class MembershipRegistry
    def initialize
      @has_members = Set.new
      @is_member_of = Set.new
    end
    attr_reader :has_members, :is_member_of
  end
  class Collection < PersistenceBase

    def self.membership_registry
      @membership_registry ||= MembershipRegistry.new
    end

    def membership_registry
      self.class.membership_registry
    end

    def self.has_members(method_name, *args)
      membership_registry.has_members << method_name
      has_many(method_name, *args)
    end

    def self.is_member_of(method_name, *args)
      membership_registry.is_member_of << method_name
      has_and_belongs_to_many(method_name, *args)
    end

    def save
      collected_has_members = membership_registry.has_members.
      collect do |association_name|
        public_send(association_name)
      end.flatten
      self.child_collections = collected_has_members

      collected_is_member_of = membership_registry.is_member_of.
      collect do |association_name|
        public_send(association_name)
      end.flatten

      self.parent_collections = collected_is_member_of

      super
    end

    belongs_to(
      :area,
      class_name:'CommonRepositoryModel::Area',
      property: :is_member_of_area
    )

    has_many(
      :child_collections,
      class_name: 'CommonRepositoryModel::Collection',
      property: :is_member_of
    )

    has_and_belongs_to_many(
      :parent_collections,
      class_name: 'CommonRepositoryModel::Collection',
      property: :is_member_of
    )

    has_many(
      :data,
      class_name: 'CommonRepositoryModel::Data',
      property: :is_part_of
    )
  end
end
