# Copied from https://github.com/curationexperts/worthwhile/blob/fcd0ea0283d267c3dc5af026aaef320af10606a1/app/models/concerns/curation_concern/has_representative.rb
module CurationConcern
  module HasRepresentative
    extend ActiveSupport::Concern

    included do
      has_attributes :representative, datastream: :properties, multiple: false
    end

    def to_solr(solr_doc={}, opts={})
      super.tap do |solr_doc|
        solr_doc[Solrizer.solr_name('representative', :stored_searchable)] = representative
      end
    end
  end
end
