class CollectorInfo
  include Mongoid::Document

  belongs_to :city

  field :latest_update, type: Time, default: 0
  field :quadrant, type: Array
end
