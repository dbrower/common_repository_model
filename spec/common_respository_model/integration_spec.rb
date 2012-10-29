require_relative '../spec_helper'
require 'common_repository_model/collection'


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
  let(:dress) { Clothing.new }

  before(:all) do
    family.save

    lawyer.save
    doctor.save

    heathcliff.save
    claire.save
    theo.save
    vanessa.save
    rudy.save

    dress.save

    claire.children = [theo,vanessa,rudy]
    claire.jobs << lawyer
    claire.families << family
    claire.data << dress
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

    @dress = dress.class.find(dress.pid)
    @theo = theo.class.find(theo.pid)
    @family = family.class.find(family.pid)
    @claire = claire.class.find(claire.pid)
  end

  it 'verifies complicated relationships' do
    assert_rels_ext(
      @family,
      :has_family_members,
      [@theo,@claire, heathcliff,rudy, vanessa]
    )

    assert_rels_ext @theo, :is_child_of, [@claire, heathcliff]
    assert_rels_ext @theo, :is_member_of, [@claire, family, heathcliff]

    assert_active_fedora_has_many(@theo, :jobs, [])
    assert_active_fedora_has_many(@theo, :families, [family])
    assert_active_fedora_has_many(@theo, :parents, [heathcliff,claire])
    assert_active_fedora_has_many(@theo, :child_collections, [])
    assert_active_fedora_has_many(
      @theo, :parent_collections, [heathcliff,claire,family]
    )

    assert_rels_ext(@dress, :is_part_of, [@claire])
    assert_active_fedora_belongs_to(@dress, :collection, @claire)

    assert_rels_ext @claire, :is_parent_of, [@theo,vanessa,rudy]
    assert_rels_ext @claire, :is_family_member_of, [family]
    assert_rels_ext @claire, :is_member_of, [family]

    assert_active_fedora_has_many(@claire,:data,[@dress])
    assert_active_fedora_has_many(@claire,:jobs,[lawyer])
    assert_active_fedora_has_many(@claire,:families,[family])
    assert_active_fedora_has_many(@claire,:children,[theo, rudy, vanessa])
    assert_active_fedora_has_many(
      @claire,:child_collections,[theo, rudy, vanessa]
    )
    assert_active_fedora_has_many(@claire,:parent_collections,[family])
  end
end
