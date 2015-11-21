module Enocean
  module Esp3
    class PacketFactory
      class << self
        def from_data(packet_type, data, optional_data = [])
          case packet_type
            when 0x01 then Radio.from_data(data, optional_data)
            when 0x02 then Response.from_data(data, optional_data)
            else BasePacket.from_data(packet_type, data, optional_data)
          end
        end
      end
    end
    
    class BasePacket
      attr_reader :data, :optional_data, :packet_type
      
      class << self
        def from_data(packet_type, data, optional_data)
          self.new(packet_type, data, optional_data)
        end
      end
      
      def initialize(packet_type, data, optional_data)
        @packet_type, @data, @optional_data = packet_type, data, optional_data
      end
      
      def header
        [@data.count, @optional_data.count, @packet_type].pack("nCC").unpack("C*")
      end

      # see Enocean Serial Protocol, section 1.6.1 Packet description
      def serialize
        [ 0x55 ] + self.header + [ crc8(header) ] + @data + @optional_data + [ crc8(@data + @optional_data) ]
      end

      def base_info
        s = "\nESP3 packet packet_type: 0x%02x (%s)\n" % [@packet_type, self.class]
        s += "Data length     : %d\n" % @data.length
        s += "Opt. data length: %d\n" % @optional_data.length
        s
      end

      def content
        ""
      end

      def to_s
        return base_info + content
      end
    end
  end
end
