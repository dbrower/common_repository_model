require_relative './persistence_base'
require_relative './area'
require_relative './data'
require 'set'
require 'morphine'

class PersistedValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    is_valid = true
    is_valid = false if value.nil?
    begin
      is_valid = false unless value.persisted?
    rescue NoMethodError
      is_valid = false
    end

    record.errors.add(attribute, 'must be persisted') unless is_valid
    is_valid
  end
end
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

    before_validation :assign_area!, on: :create
    def assign_area!
      self.__area =
      if area
        CommonRepositoryModel::Area.find(area.pid)
      else
        CommonRepositoryModel::Area.find_by_name!(name_of_area_to_assign)
      end
    rescue CommonRepositoryModel::ObjectNotFoundError
      false
    end
    protected :assign_area!

    def name_of_area_to_assign
      'NDLIB'
    end

    before_save :register_parent_and_collections
    def register_parent_and_collections
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

      true
    end
    protected :register_parent_and_collections

    def is_root?
      parent_collections.size == 0
    end

    def parent_areas
      parent_collections.collect(&:__area).uniq
    end

    def area
      if is_root?
        __area
      else
        parent_areas.first
      end ||
      CommonRepositoryModel::Area.find_by_name!(name_of_area_to_assign)
    rescue CommonRepositoryModel::ObjectNotFoundError
      nil
    end

    def area_name
      area.name
    end

    belongs_to(
      :__area,
      class_name:'CommonRepositoryModel::Area',
      property: :is_member_of_area
    )

    validates :area, presence: true, persisted: true

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
