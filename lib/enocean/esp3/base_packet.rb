module Enocean
  module Esp3
    class BasePacket
      attr_reader :data, :optional_data, :packet_type
      def initialize(packet_type, data, optional_data = [])
        @packet_type = packet_type
        @data = data
        @optional_data = optional_data
        init_from_data
      end

      def init_from_data
      end
      
      def self.from_data(data = [], optional_data = [])
        return self.new(type_id, data, optional_data)
      end

      def header
        [@data.count, @optional_data.count, @packet_type].pack("nCC").unpack("C*")
      end

      # see Enocean Serial Protocol, section 1.6.1 Packet description
      def serialize
        [ 0x55 ] + self.header + [ crc8(header) ] + @data + @optional_data + [ crc8(@data + @optional_data) ]
      end

      def base_info
        s = "\nESP3 packet type: 0x%02x (%s)\n" % [@packet_type, self.class]
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

      def self.factory(packet_type, data, optional_data)

        if packet_type == Radio.type_id
          return Radio.from_data(data, optional_data)
        elsif packet_type == Response.type_id
          return Response.from_data(data,  optional_data)
        else
          # add all other packet type
          # fall back for unknown packets
          return BasePacket.new(packet_type,  data,  optional_data)
        end
      end
    end
  end
end
