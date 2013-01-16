require 'rdf'
class CommonRepositoryModel::CustomVocabulary < RDF::Vocabulary('http://library.nd.edu/meta_data/terms/')
  property :identifierDOI
  property :identifierURI
  property :identifierOther
  property :dateDigitized
  property :dateAccessioned
  property :publisherRepository
  property :publisherDigital
  property :publisherInstitution
  property :equipmentDigitizing
  property "isPartOf.ISSN".to_sym
end
