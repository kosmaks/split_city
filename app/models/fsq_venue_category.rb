class FsqVenueCategory
  include Mongoid::Document
  embedded_in :venue_category

  field :name, type: String
  field :category_id, type: String, default: ""
end
