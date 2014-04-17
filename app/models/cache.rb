class Cache
  include Mongoid::Document
  field :data, type: Hash
  field :n, type: Integer
end
