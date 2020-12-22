# RPS Telegram message
# Contains only one byte of data
# RORG = 0xf6
# Will perform like a PT200 switch
# pressed => F6-02-01 first part (T21, NU are 1)
# not pressed => F6-02-01 second part (T21 is 1, NU is 0)
module Enocean
  module Esp3
    class Rps < Radio
      
      def self.buttons
        [ :a1, :a0, :b1, :b0 ]
      end
      
      def self.rorg
        0xf6
      end
      
      def self.from_data(data, optional_data = [])
        Rps.new.from_data(data, optional_data)
      end
      
      def from_data(data, optional_data = [])
        @radio_data = data[1..1]
        @sender_id = data[2..5].pack("C*").unpack("N").first
        @status = data[-1]
        @subTelNum,  @destId,  @dBm,  @securityLevel = optional_data.pack("C*").unpack("BNBB") #struct.unpack('>BIBB',  str(self.optional_data))
        @repeatCount = @status & 0x0F
        @repeatCount = @status & 0x0F
        # T21 and NU flags as tuple
        @flags = {:t21 => (@status >> 5) & 0x01, :nu => (@status >> 4) & 0x01 }
        self
      end
      
      attr_accessor :flags
      
      def initialize
        super([  ], [])
        self.radio_data = [ 0 ]
        self.rorg = Rps.rorg
        @flags = { :t21 => 1, :nu => 0 }
      end

      def build_data
        @data = ([ self.rorg ] + [ self.radio_data ] + self.sender_id + [ self.flags[:t21] >> 5 | self.flags[:nu] >> 4 ]).flatten
      end
      
      def rps_data
        radio_data.first
      end
      
      def action1
        Rps.buttons[rps_data >> 5]
      end

      def action2
        raise "Second action not supported"
      end
      
      # second action not supported for sending currently
      def action1=(value)
        @radio_data = [ (Rps.buttons.index(value) << 5) | ( 1 << 4 )]
      end

      def release?
        @flags[:nu].zero?
      end

      def to_s
        if ! @flags[:nu].zero? && ! @flags[:t21].zero?
          "Rocker@#{sender_id}: Action1 #{action1} " 
        else
          "Rocker@#{sender_id}: released (#{radio_data})"
        end
      end
    end
  end
end