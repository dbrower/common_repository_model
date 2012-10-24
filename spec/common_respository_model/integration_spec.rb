require_relative '../spec_helper'
require 'common_repository_model/collection'

class Person < CommonRepositoryModel::Collection
  has_and_belongs_to_many(
    :parents,
    class_name: 'Person',
    property: :is_child_of,
    inverse_of: :is_parent_of
  )

  has_and_belongs_to_many(
    :children,
    class_name: 'Person',
    property: :is_parent_of,
    inverse_of: :is_child_of
  )

end

describe CommonRepositoryModel::Collection do
  let(:heathcliff) { Person.new }
  let(:claire) { Person.new }
  let(:theo) { Person.new }
  let(:vanessa) { Person.new }
  let(:rudy) { Person.new }

  it {
    heathcliff.save
    claire.save
    theo.save
    vanessa.save
    rudy.save

    claire.children = [theo,vanessa,rudy]
    claire.save
    heathcliff.children = [theo,vanessa,rudy]
    heathcliff.save

    reloaded_theo = theo.class.find(theo.pid)
    reloaded_theo.parent_collections.size.must_equal 2
    reloaded_theo.parents.size.must_equal 2

    reloaded_claire = claire.class.find(claire.pid)
    reloaded_claire.child_collections.size.must_equal 3
    reloaded_claire.children.size.must_equal 3
  }
end
