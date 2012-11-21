
module Enocean
  module Esp3
    class Response < BasePacket
      
      class << self
        def packet_type
          0x02
        end
        def from_data(packet_type, data = [], optional_data = [])
          self.new(packet_type, data, optional_data)
        end
      end

      def return_code
        data.first
      end

      def ok?
        return_code == 0
      end

    end

    class ReadIdBaseResponse < Response
      def base_id
        data[1,4]
      end
      def self.from_packet(packet)
        self.from_data(packet.packet_type, packet.data, packet.optional_data)
      end
    end
  end
end
