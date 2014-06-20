class Collection < ActiveFedora::Base
  include Sufia::Collection
  include CurationConcern::HasRepresentative
end
