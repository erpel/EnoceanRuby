
module Enocean
  module Esp3
    class CommonCommand < BasePacket
      def self.with_command(cmd, data = [], optional_data = [])
        data.insert(0, cmd)
        return self.new(0x05, data, optional_data)
      end
    end


    # CO_RD_IDBASE
    class ReadIdBase < CommonCommand
      def self.create
        with_command(0x08)
      end
    end
  end
end

