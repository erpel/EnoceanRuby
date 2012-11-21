# RPS Telegram message
# Contains only one byte of data
# RORG = 0xf6
module Enocean
  module Esp3
    class Rps < Radio
      
      class << self
        def rorg
          0xf6
        end
      end
      
      def rps_data
        radio_data.first
      end
    end

    class PTM200 < Rps
      class << self
        def from_packet(packet)
          self.from_data(packet.data, packet.optional_data)
        end
      end

      def initialize(*args)
        super
        @buttons = [ :a1, :a0, :b1, :b0 ]
      end

      def action1
        @buttons[rps_data >> 5]
      end

      def action2
        @buttons[(rps_data >> 1) & 0b111] if ! ( rps_data & 1 ).zero?
      end

      def to_s
        if ! flags[:nu].zero? && ! flags[:t21].zero?
          "Rocker@#{sender_id}: Action1 #{action1} , Action2: #{action2}" 
        else
          "Rocker@#{sender_id}: released (#{radio_data})"
        end
      end
      
      def self.pressed(sender_id, button)
        result = PTM200.new( [0x00] )
        result.sender_id = sender_id
      end
    end
  end
end