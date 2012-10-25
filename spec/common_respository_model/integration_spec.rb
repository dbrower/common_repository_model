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
  before(:all) do
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
  end
  let(:family) { Family.new }
  let(:lawyer) { Job.new }
  let(:doctor) { Job.new }
  let(:heathcliff) { Person.new }
  let(:claire) { Person.new }
  let(:theo) { Person.new }
  let(:vanessa) { Person.new }
  let(:rudy) { Person.new }

  it 'verifies complicated relationships' do
    @theo = theo.class.find(theo.pid)
    @family = family.class.find(family.pid)
    @claire = claire.class.find(claire.pid)

    assert_rels_ext(
      @family,
      :has_family_members,
      [@theo,@claire, heathcliff,rudy, vanessa]
    )

    assert_rels_ext @theo, :is_child_of, [@claire, heathcliff]
    assert_rels_ext @theo, :is_member_of, [@claire, family, heathcliff]

    assert_af_association(@theo, :jobs, [])
    assert_af_association(@theo, :families, [family])
    assert_af_association(@theo, :parents, [heathcliff,claire])
    assert_af_association(@theo, :child_collections, [])
    assert_af_association(
      @theo, :parent_collections, [heathcliff,claire,family]
    )

    assert_rels_ext @claire, :is_parent_of, [@theo,vanessa,rudy]
    assert_rels_ext @claire, :is_family_member_of, [family]
    assert_rels_ext @claire, :is_member_of, [family]

    assert_af_association(@claire,:jobs,[lawyer])
    assert_af_association(@claire,:families,[family])
    assert_af_association(@claire,:children,[theo, rudy, vanessa])
    assert_af_association(@claire,:child_collections,[theo, rudy, vanessa])
    assert_af_association(@claire,:parent_collections,[family])
  end

  def assert_rels_ext(subject, predicate, objects = [])
    subject.relationships(predicate).count.must_equal(objects.count)
    objects.each do |object|
      internal_uri = object.respond_to?(:internal_uri) ?
        object.internal_uri : object
      subject.relationships(predicate).must_include(internal_uri)
    end
  end

  def assert_af_association(subject, method_name, objects)
    association = subject.send(method_name)
    association.count.must_equal(objects.count)
    objects.each do |object|
      association.must_include(object)
    end
  end
end
