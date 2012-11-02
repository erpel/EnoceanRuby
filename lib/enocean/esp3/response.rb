
module Enocean
  module Esp3
    class Response < BasePacket

      def self.type_id
        return 0x02
      end
  
      def return_code
        data.first
      end
  
      def ok?
        return_code == 0
      end
  
      def self.from_data(data = [], optional_data = [])
        return self.new(type_id, data, optional_data)
      end

    end
  end
end
