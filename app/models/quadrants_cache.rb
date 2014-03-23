class QuadrantsCache
  include Mongoid::Document

  field :quadrants,  type: Array
end
