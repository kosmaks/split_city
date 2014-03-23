class City
  include Mongoid::Document

  field :name,    type: String
  field :borders, type: Array
end
