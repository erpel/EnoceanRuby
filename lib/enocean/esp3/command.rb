
module Enocean
  module Esp3
    class CommonCommand < BasePacket
      def self.type_id
        return 0x05
      end

      def self.withCommand(cmd, data = [], optional_data = [])
        data.insert(0, cmd)
        return self.new(type_id, data, optional_data)
      end
    end


    # CO_RD_IDBASE
    class ReadIdBase < CommonCommand
      def self.create
        withCommand(0x08)
      end
    end
    
    class ReadIdBaseResponse < Response
      def base_id
        data[1,4]
      end
      def self.factory(packet_type, data, optional_data)
        self.from_data(data)
      end
    end
  end
end

