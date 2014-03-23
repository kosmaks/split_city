class CollectorInfo
  include Mongoid::Document

  field :latest_update, type: Time
  field :quadrant, type: Array
end
