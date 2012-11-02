
module Enocean
  module Esp3
    class Radio < BasePacket
  
      attr_accessor :sender_id, :radio_data, :rorg

      def init_from_data
        @rorg = @data[0]
        @radio_data = @data[1..-6]
        @sender_id = @data[-5..-2].pack("C*").unpack("N").first
        @status = @data[-1]
        @subTelNum,  @destId,  @dBm,  @securityLevel = @optional_data.pack("C*").unpack("BNBB") #struct.unpack('>BIBB',  str(self.optional_data))
        @repeatCount = @status & 0x0F
        # T21 and NU flags as tuple
        @flags = {:t21 => (@status >> 5) & 0x01, :nu => (@status >> 4) & 0x01 }
      end

      def self.type_id
        return 0x01
      end

      def self.from_data(data = [], optional_data = [])
        return self.new(type_id, data, optional_data)
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
    end
  end
end
