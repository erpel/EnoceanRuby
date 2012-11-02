
module Enocean
  module Esp3
    class CommonCommand < BasePacket
      def self.typeId
        return 0x05
      end

      def self.withCommand(cmd, data = [], optional_data = [])
        data.insert(0, cmd)
        return self.new(typeId, data, optional_data)
      end
    end

    class ReadIdBase < CommonCommand
      def self.create
        withCommand(0x08)
      end
    end
  end
end

