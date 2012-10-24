require_relative '../spec_helper'
require 'common_repository_model/collection'

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
    property: :has_family_members,
    inverse_of: :is_family_member_of
  )
end

class Person < CommonRepositoryModel::Collection

  is_member_of(
    :parents,
    class_name: 'Person',
    property: :is_child_of,
    inverse_of: :is_parent_of
  )

  has_members(
    :children,
    class_name: 'Person',
    property: :is_parent_of,
    inverse_of: :is_child_of
  )

  # People can be part of multiple families
  is_member_of(
    :families,
    class_name: 'Family',
    property: :is_family_member_of,
    inverse_of: :has_family_members,
  )

  has_and_belongs_to_many(
    :jobs,
    class_name: 'Job',
    property: :is_working_as,
    inverse_of: :has_workers
  )

end

describe CommonRepositoryModel::Collection do
  let(:family) { Family.new }
  let(:lawyer) { Job.new }
  let(:doctor) { Job.new }
  let(:heathcliff) { Person.new }
  let(:claire) { Person.new }
  let(:theo) { Person.new }
  let(:vanessa) { Person.new }
  let(:rudy) { Person.new }

  it 'verifies complicated relationships' do
    family.save

    lawyer.save
    doctor.save

    heathcliff.save
    claire.save
    theo.save
    vanessa.save
    rudy.save

    claire.children = [theo,vanessa,rudy]
    claire.jobs << lawyer
    claire.families << family
    claire.save

    heathcliff.children = [theo,vanessa,rudy]
    heathcliff.jobs << doctor
    heathcliff.families << family
    heathcliff.save

    theo.families << family
    theo.save
    vanessa.families << family
    vanessa.save
    rudy.families << family
    rudy.save

    reloaded_theo = theo.class.find(theo.pid)

    reloaded_theo.jobs.size.must_equal 0
    reloaded_theo.families.size.must_equal 1
    reloaded_theo.parents.size.must_equal 2

    reloaded_theo.child_collections.count.must_equal 0

    reloaded_theo.parent_collections.must_include(heathcliff)
    reloaded_theo.parent_collections.must_include(claire)
    reloaded_theo.parent_collections.must_include(family)

    reloaded_claire = claire.class.find(claire.pid)
    reloaded_claire.jobs.size.must_equal 1
    reloaded_claire.families.size.must_equal 1
    reloaded_claire.children.size.must_equal 3

    reloaded_claire.child_collections.must_include(theo)
    reloaded_claire.child_collections.must_include(vanessa)
    reloaded_claire.child_collections.must_include(rudy)

    reloaded_claire.parent_collections.must_include(family)
  end
end
