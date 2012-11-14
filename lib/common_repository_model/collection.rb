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

    def self.has_members(method_name, options = {})
      membership_registry.has_members << method_name
      has_many(method_name, options)
    end

    # Creates the :break_relation_with_<macro_name> method which is useful for
    # managing both the ActiveFedora association and relationship.
    #
    # NOTE: I believe this is actually masking an ActiveFedora bug, at some
    # point, I would imagine that the :break_relation_with method would be
    # deprecated and ultimately be an alias for
    # object.<association_name>.delete(obj1,obj2)
    def self.is_member_of(method_name, options = {})
      membership_registry.is_member_of << method_name
      define_method "break_relation_with_#{method_name}" do |*args|
        send(method_name).delete(*args)
        args.each do |obj|
          remove_relationship(options[:property], obj)
          remove_relationship(:is_member_of, obj)
        end
      end
      has_and_belongs_to_many(method_name, options)
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

    def find_or_build_data_for_given_slot_names(slot_names)
      slot_names.collect { |name|
        data.detect { |d| d.slot_name == name } || data.build(slot_name: name)
      }
    end
  end
end
