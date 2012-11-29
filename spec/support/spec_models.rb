require 'common_repository_model/collection'

class JournalVolume < CommonRepositoryModel::Collection
  def name_of_area_to_assign
    Journal::AREA_NAME.freeze
  end

  is_member_of :journals, class_name: "Journal", property: :is_volume_of
end

class Journal < CommonRepositoryModel::Collection
  AREA_NAME ='NDLIB-LAW'.freeze
  def name_of_area_to_assign
    AREA_NAME
  end

  has_members :volumes, class_name: "JournalVolume", property: :is_volume_of
end

class Clothing < CommonRepositoryModel::Data
end

class Job < CommonRepositoryModel::Collection
  has_and_belongs_to_many(
    :people,
    class_name: 'Person',
    property: :has_workers,
    inverse_of: :is_working_as
  )
end

class Family < CommonRepositoryModel::Collection
  has_members(
    :family_members,
    class_name: 'Person',
    property: :is_family_member_of
  )
end

class Person < CommonRepositoryModel::Collection

  is_member_of(
    :parents,
    class_name: 'Person',
    property: :is_child_of
  )

  has_members(
    :children,
    class_name: 'Person',
    property: :is_child_of
  )

  # People can be part of multiple families
  is_member_of(
    :families,
    class_name: 'Family',
    property: :is_family_member_of
  )

  has_and_belongs_to_many(
    :jobs,
    class_name: 'Job',
    property: :is_working_as,
    inverse_of: :has_workers
  )

end