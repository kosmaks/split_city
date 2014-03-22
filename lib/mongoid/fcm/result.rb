module Mongoid
  class FCM
    module Result
      def self.included o
        o.field :_id, type: Integer
        o.field :value, type: Hash
      end
    end
  end 
end
