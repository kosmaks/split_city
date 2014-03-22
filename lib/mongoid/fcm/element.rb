module Mongoid
  class FCM
    module Element
      module Static
        def fcm_key *keys
          @fcm_keys ||= []   
          @fcm_keys += keys
          @fcm_keys
        end

        def fcm_keys
          @fcm_keys || []
        end
      end

      def self.included o
        o.extend Static
      end
    end
  end 
end
