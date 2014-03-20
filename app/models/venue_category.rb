class VenueCategory
  include Mongoid::Document

  has_and_belongs_to_many :venues
  embeds_one :fsq_venue_category

  field :name, type: String, default: ""
end
