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

describe CommonRepositoryModel::Collection do
  let(:area) { FactoryGirl.create(:area) }
  let(:family) { Family.new(area: area) }
  let(:lawyer) { Job.new(area: area) }
  let(:doctor) { Job.new(area: area) }
  let(:heathcliff) { Person.new(area: area) }
  let(:claire) { Person.new(area: area) }
  let(:theo) { Person.new(area: area) }
  let(:vanessa) { Person.new(area: area) }
  let(:rudy) { Person.new(area: area) }
  let(:dress) { Clothing.new(slot_name: 'outerwear') }

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

    family.family_members = [claire,heathcliff,theo,vanessa,rudy]
    family.save.must_equal true

    @dress = dress.class.find(dress.pid)
    @theo = theo.class.find(theo.pid)
    @family = family.class.find(family.pid)
    @claire = claire.class.find(claire.pid)
    @rudy = rudy.class.find(rudy.pid)
  end

  it 'verifies complicated relationships' do
    verify_initial_relations_for_family
    verify_initial_relations_for_theo
    verify_initial_relations_for_claire
    verify_initial_relations_for_dress

    verify_claire_adding_a_child

    verify_claire_losing_a_child

    verify_rudy_losing_a_parent
  end

  protected
  def verify_initial_relations_for_family
    # We are not storing the RELS-EXT entry on the "container" collection
    assert_rels_ext(
      @family,
      :has_family_members,
      []
    )
    assert_rels_ext(
      @family,
      :has_members,
      []
    )

    # However, we do have access to Family#family_members
    assert_active_fedora_has_many(
      @family,
      :family_members,
      [@theo,@claire, heathcliff,rudy, vanessa]
    )

    assert_active_fedora_has_many(
      @family,
      :child_collections,
      [@theo,@claire, heathcliff,rudy, vanessa]
    )
  end

  def verify_initial_relations_for_theo
    assert_rels_ext @theo, :is_child_of, [@claire, heathcliff]
    assert_rels_ext @theo, :is_member_of, [@claire, family, heathcliff]

    assert_active_fedora_has_many(@theo, :jobs, [])
    assert_active_fedora_has_many(@theo, :families, [family])
    assert_active_fedora_has_many(@theo, :parents, [heathcliff,claire])
    assert_active_fedora_has_many(@theo, :child_collections, [])
    assert_active_fedora_has_many(
      @theo, :parent_collections, [heathcliff,claire,family]
    )
  end

  def verify_initial_relations_for_dress
    assert_rels_ext(@dress, :is_part_of, [@claire])
    assert_active_fedora_belongs_to(@dress, :collection, @claire)
  end

  def verify_initial_relations_for_claire
    assert_rels_ext @claire, :is_parent_of, []
    assert_rels_ext @claire, :is_child_of, []
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

  def verify_claire_adding_a_child
    sandra = Person.new(area: area)
    sandra.save
    @claire.children << sandra
    @claire.save
    @claire = @claire.class.find(@claire.pid)

    assert_rels_ext @claire, :is_parent_of, []
    assert_rels_ext @claire, :is_child_of, []

    assert_active_fedora_has_many(@claire,:parents,[])
    assert_active_fedora_has_many(@claire,:children,[theo, rudy, vanessa,sandra])
    assert_active_fedora_has_many(
      @claire,:child_collections,[theo, rudy, vanessa, sandra]
    )
    assert_active_fedora_has_many(
      @claire,:parent_collections,[family]
    )
  end

  def verify_claire_losing_a_child
    @claire.children = [theo,rudy]
    @claire.save

    assert_active_fedora_has_many(@claire,:children,[theo, rudy])
    assert_active_fedora_has_many(
      @claire,:child_collections,[theo, rudy]
    )

    reloaded_vanessa = vanessa.class.find(vanessa.pid)

    # Note, just because we said Claire was not Vanessa's parent, Vanessa did
    # not update
    assert_rels_ext reloaded_vanessa, :is_child_of, [claire, heathcliff]
    assert_rels_ext(
      reloaded_vanessa, :is_member_of, [claire, heathcliff, family]
    )

    assert_active_fedora_has_many(
      reloaded_vanessa, :parents, [claire, heathcliff]
    )
    assert_active_fedora_has_many(
      reloaded_vanessa, :parent_collections, [claire,heathcliff, family]
    )

  end

  def verify_rudy_losing_a_parent
    assert_rels_ext @rudy, :is_child_of, [heathcliff,claire]
    assert_rels_ext @rudy, :is_member_of, [heathcliff,claire,family]
    assert_active_fedora_has_many @rudy, :parents, [heathcliff,claire]
    assert_active_fedora_has_many(
      @rudy, :parent_collections, [heathcliff,claire,family]
    )

    @rudy.break_relation_with_parents(heathcliff)
    @rudy.save.must_equal true

    assert_active_fedora_has_many(@rudy, :parents, [claire])
    assert_active_fedora_has_many(@rudy, :parent_collections, [claire, family])
    assert_rels_ext @rudy, :is_child_of, [claire]
    assert_rels_ext @rudy, :is_member_of, [claire, family]

    @rudy = @rudy.class.find(@rudy.pid)

    assert_rels_ext @rudy, :is_child_of, [claire]
    assert_rels_ext @rudy, :is_member_of, [claire, family]

    assert_active_fedora_has_many(@rudy, :parents, [claire])
    assert_active_fedora_has_many(@rudy, :parent_collections, [claire, family])
  end
end
