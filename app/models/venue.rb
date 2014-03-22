class Venue
  include Mongoid::Document
  include Mongoid::FCM::Element

  has_and_belongs_to_many :categories, :class_name => "VenueCategory"

  field :name, type: String

  field :venue_id, type: String

  field :lat,  type: Float
  field :lng,  type: Float

  fcm_key :lat, :lng
end
