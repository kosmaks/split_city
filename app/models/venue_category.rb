class VenueCategory
  include Mongoid::Document

  embeds_one :fsq_venue_category

  field :name, type: String, default: ""
end
