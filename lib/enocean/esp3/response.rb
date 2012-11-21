
module Enocean
  module Esp3
    class Response < BasePacket
      
      class << self
        
        def packet_type
          0x02
        end
        
        def from_data(data, optional_data = [])
          self.new(packet_type, data, optional_data)
        end
      end

      def return_code
        data.first
      end

      def ok?
        return_code == 0
      end
      
      def as_read_id_response
        self.extend ReadIdBaseResponse
        self
      end
      
    end

    module ReadIdBaseResponse 

      def base_id
        data[1,4]
      end
      
    end
  end
end
