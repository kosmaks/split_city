class Venue
  include Mongoid::Document

  has_many :category, :class_name => "VenueCategory"

  field :name, type: String
  field :lat,  type: Float
  field :lng,  type: Float
end
