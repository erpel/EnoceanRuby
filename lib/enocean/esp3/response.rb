module Enocean
  module Esp3
    class Response < BasePacket

      def self.typeId
        return 0x02
      end

      def self.fromData(data = [], optional_data = [])
        return self.new(typeId, data, optional_data)
      end

    end
  end
end