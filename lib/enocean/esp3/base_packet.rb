module Enocean
  module Esp3
    class BasePacket
      attr_reader :data, :optional_data, :packet_type
      def initialize(packet_type, data, optional_data = [])
        @packet_type = packet_type
        @data = data
        @optional_data = optional_data
        initFromData
      end

      def initFromData()
      end

      def self.fromData(data = [], optional_data = [])
        return self.new(typeId, data, optional_data)
      end

      def header
        header = ([@data.count, @optional_data.count, @packet_type].pack("nCC")).unpack("C*")
        header << crc8(header)
        header.insert(0 , 0x55)
        return header
      end

      def serialize
        pkt = self.header + @data + @optional_data
        pkt << crc8(@data + @optional_data)
        pkt
      end

      def printBaseInfo
        s = "\nESP3 packet type: 0x%02x (%s)\n" % [@packet_type, self.class]
        s += "Data length     : %d\n" % @data.length
        s += "Opt. data length: %d\n" % @optional_data.length
        return s
      end

      def printContent
        return ""
      end

      def to_s
        return self.printBaseInfo + self.printContent
      end

      def self.factory(packet_type, data, optional_data)

        if packet_type == Radio.typeId
          return Radio.fromData(data, optional_data)
        elsif packet_type == Response.typeId
          return Response.fromData(data,  optional_data)
        else
              # add all other packet type
                # fall back for unknown packets
                return BasePacket.new(packet_type,  data,  optional_data)
              end
          end
      end
    end
  end
end