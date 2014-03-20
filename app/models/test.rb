class Test
  include Mongoid::Document
  include Mongoid::FCM

  field :value, type: Float
end
