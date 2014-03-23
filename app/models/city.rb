class City
  include Mongoid::Document
  has_many :collector_info, :class_name => "CollectorInfo"

  field :name,    type: String
  field :borders, type: Array
end
