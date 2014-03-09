class VenueCategory
  include Mongoid::Document

  belongs_to :parent, :class_name => "VenueCategory"
  has_many   :childs, :class_name => "VenueCategory"

  field :name, type: String, default: ""
  field :hash, type: String, default: ""
end
