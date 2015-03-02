
module Enocean
  module Esp3
    
    class RadioFactory
      class << self
        def from_data(data, optional_data)
          case data[0]
          when 0xf6 then Rps.from_data(data, optional_data)
          else Radio.from_data(data, optional_data)
          end
        end
      end
    end
    
    # Radio package:
    # Header
    # Data (byte offsets)
    #   0: RORG (type of radio package)
    #   1: Data 
    #   2-4: sender_id
    #   5: status field
    class Radio < BasePacket

      class << self
        def packet_type
          0x01
        end
 
        def from_data(data, optional_data = [])
          result = self.new(data, optional_data)
          result.parse_data
          result
        end

        # TODO create a telegram
        def create
        end
      end  

      attr_accessor :sender_id, :radio_data, :rorg, :flags
      
      def initialize(data, optional_data)
        super(Radio.packet_type, data, optional_data)
      end
      
      def content
        s =<<-EOT
        **** Received at: #{Time.now} ******
        **** Data ****
        Choice          : 0x#{@rorg.to_s(16)}
        Data            : 0x#{@radio_data.collect{ |d| d.to_s(16) }.join("-")}
        Sender ID       : 0x#{@sender_id.to_s(16)}
        Status          : 0x#{@status.to_s(16)}
        **** Optional Data ****
        EOT
        if @optional_data.count > 0
          #s +=  'SubTelNum       : {0:d}\n'.format(self.subTelNum)
          #s +=  'Destination ID: 0x{0:08x}\n'.format(self.destId)
          #s +=  'dBm             : {0:d}\n'.format(self.dBm)
          #s +=  'Security Level  : {0:d}\n'.format(self.SecurityLevel)
        else
          #s +=  'None\n'
        end
        return s
      end

      def parse_data
        @rorg = data[0]
        @radio_data = data[1..-6]
        @sender_id = data[-5..-2].pack("C*").unpack("N").first
        @status = data[-1]
        @subTelNum,  @destId,  @dBm,  @securityLevel = optional_data.pack("C*").unpack("BNBB") #struct.unpack('>BIBB',  str(self.optional_data))
        @repeatCount = @status & 0x0F
        @repeatCount = @status & 0x0F
        # T21 and NU flags as tuple
        @flags = {:t21 => (@status >> 5) & 0x01, :nu => (@status >> 4) & 0x01 }
      end
    end
  end
end
