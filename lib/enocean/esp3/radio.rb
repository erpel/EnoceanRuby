
module Enocean
  module Esp3
    
    
    # Radio package, main package for 4BS and RPS data
    # Header
    # Data (byte offsets)
    #   0 byte: RORG (type of radio package)
    #   1-4 bytes: Radio data 
    #   4   bytes: sender_id
    #   5: status field
    class Radio < BasePacket

      class << self
        def packet_type
          0x01
        end
 
        def from_data(data, optional_data = [])
          result = nil
          if data[0] == Rps.rorg
            result = Rps.from_data(data, optional_data)
          elsif data[0] == FourBS.rorg
            result = FourBS.from_data(data, optional_data) 
          end
          result
        end

      end  

      attr_accessor :sender_id, :radio_data, :rorg, :flags, :status
      
      def initialize(data, optional_data)
        super(Radio.packet_type, data, optional_data)
        self.sender_id = [ 0xff, 0xff, 0xff, 0xff ]
        self.status = 0
      end
      
      def build_data
        raise "This needs to be defined by the subclass"
      end
      
      def content
        
        s =<<-EOT
        **** Received at: #{Time.now} ******
        **** Data ****
        Choice          : 0x#{rorg.to_s(16)}
        Data            : 0x#{radio_data.flatten.collect{ |d| d.to_s(16) }.join("-")}
        Sender ID       : 0x#{sender_id.collect{ | i| i.to_s(16)}.join(":")}
        Status          : 0x#{status.to_s(16)}
        **** Optional Data ****
        EOT
        return s
      end
      
    end
  end
end
