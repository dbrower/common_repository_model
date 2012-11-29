require_relative '../spec_helper'
require_relative '../support/spec_models'

describe CommonRepositoryModel::Collection do
  describe 'with journal / volume' do
    it 'should have volumes' do
      journal = Journal.new
      with_persisted_area(journal.name_of_area_to_assign) do |area|
        journal.save!
        volume = JournalVolume.new
        volume.save!
        volume.journals << journal
        volume.save!

        @journal = journal.class.find(journal.pid)
        @volume = volume.class.find(volume.pid)

        assert_rels_ext(@volume, :is_volume_of, [@journal])
        assert_rels_ext(@volume, :is_member_of, [@journal])
        assert_active_fedora_has_many(@volume, :journals, [@journal])

        assert_rels_ext(@journal, :is_volume_of, [])
        assert_rels_ext(@journal, :is_member_of, [])
        assert_active_fedora_has_many(@journal, :volumes, [@volume])

      end
    end
  end
  describe 'with family' do
    let(:family) { Family.new }
    let(:lawyer) { Job.new }
    let(:doctor) { Job.new }
    let(:heathcliff) { Person.new }
    let(:claire) { Person.new }
    let(:theo) { Person.new }
    let(:vanessa) { Person.new }
    let(:rudy) { Person.new }
    let(:dress) { Clothing.new(slot_name: 'outerwear') }

    it 'verifies complicated relationships' do
      with_persisted_area(Family.new.name_of_area_to_assign) do |area|
        setup_variables
        verify_initial_relations_for_family
        verify_initial_relations_for_theo
        verify_initial_relations_for_claire
        verify_initial_relations_for_dress
        verify_claire_adding_a_child
        verify_claire_losing_a_child
        verify_rudy_losing_a_parent
      end
    end

    protected
    def setup_variables
      family.save!

      lawyer.save!
      doctor.save!

      heathcliff.save!
      claire.save!
      theo.save!
      vanessa.save!
      rudy.save!

      dress.save!

      claire.children = [theo,vanessa,rudy]
      claire.jobs << lawyer
      claire.families << family
      claire.data << dress
      claire.save!

      heathcliff.children = [theo,vanessa,rudy]
      heathcliff.jobs << doctor
      heathcliff.families << family
      heathcliff.save!

      theo.families << family
      theo.save!
      vanessa.families << family
      vanessa.save!
      rudy.families << family
      rudy.save!

      family.family_members = [claire,heathcliff,theo,vanessa,rudy]
      family.save!

      @dress = dress.class.find(dress.pid)
      @theo = theo.class.find(theo.pid)
      @family = family.class.find(family.pid)
      @claire = claire.class.find(claire.pid)
      @rudy = rudy.class.find(rudy.pid)
      @vanessa = vanessa.class.find(vanessa.pid)
    end
    def verify_initial_relations_for_family
      # We are not storing the RELS-EXT entry on the "container" collection
      assert_rels_ext(@family,:has_family_members,[])
      assert_rels_ext(@family,:has_members,[])

      # However, we do have access to Family#family_members
      assert_active_fedora_has_many(
        @family,
        :family_members,
        [@theo,@claire, heathcliff,rudy, @vanessa]
      )

      assert_active_fedora_has_many(
        @family,
        :child_collections,
        [@theo,@claire, heathcliff,rudy, @vanessa]
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
      assert_active_fedora_has_many(@claire,:children,[theo, rudy, @vanessa])
      assert_active_fedora_has_many(
        @claire,:child_collections,[theo, rudy, @vanessa]
      )
      assert_active_fedora_has_many(@claire,:parent_collections,[family])
    end

    def verify_claire_adding_a_child
      @sandra = Person.new
      @sandra.save!
      @claire.children << @sandra
      @claire.save!
      @claire = @claire.class.find(@claire.pid)
      @sandra = @sandra.class.find(@sandra.pid)

      assert_rels_ext @claire, :is_parent_of, []
      assert_rels_ext @claire, :is_child_of, []

      assert_active_fedora_has_many(@claire,:parents,[])
      assert_active_fedora_has_many(@claire,:children,[theo, rudy, @vanessa,@sandra])
      assert_active_fedora_has_many(
        @claire,:child_collections,[theo, rudy, @vanessa, @sandra]
      )
      assert_active_fedora_has_many(
        @claire,:parent_collections,[family]
      )
    end

    def verify_claire_losing_a_child
      @vanessa.break_relation_with_parents(@claire)
      @vanessa.save!
      @sandra.break_relation_with_parents(@claire)
      @sandra.save!

      @claire.save!
      @claire = @claire.class.find(@claire.pid)

      assert_active_fedora_has_many(@claire,:children,[theo, rudy])
      assert_active_fedora_has_many(
        @claire,:child_collections,[theo, rudy]
      )

      @vanessa = @vanessa.class.find(@vanessa.pid)

      # Note, just because we said Claire was not Vanessa's parent, Vanessa did
      # not update
      assert_rels_ext(@vanessa, :is_child_of, [heathcliff])
      assert_rels_ext(@vanessa, :is_member_of, [heathcliff, family])

      assert_active_fedora_has_many(@vanessa, :parents, [heathcliff])
      assert_active_fedora_has_many(
        @vanessa, :parent_collections, [heathcliff, family]
      )

    end

    def verify_rudy_losing_a_parent
      assert_rels_ext @rudy, :is_child_of, [heathcliff,@claire]
      assert_rels_ext @rudy, :is_member_of, [heathcliff,@claire,family]
      assert_active_fedora_has_many @rudy, :parents, [heathcliff,@claire]
      assert_active_fedora_has_many(
        @rudy, :parent_collections, [heathcliff,@claire,family]
      )

      @rudy.break_relation_with_parents(heathcliff)
      @rudy.save!

      assert_active_fedora_has_many(@rudy, :parents, [@claire])
      assert_active_fedora_has_many(@rudy, :parent_collections, [@claire, family])
      assert_rels_ext @rudy, :is_child_of, [@claire]
      assert_rels_ext @rudy, :is_member_of, [@claire, family]

      @rudy = @rudy.class.find(@rudy.pid)

      assert_rels_ext @rudy, :is_child_of, [@claire]
      assert_rels_ext @rudy, :is_member_of, [@claire, family]

      assert_active_fedora_has_many(@rudy, :parents, [@claire])
      assert_active_fedora_has_many(@rudy, :parent_collections, [@claire, family])
    end
  end
end
