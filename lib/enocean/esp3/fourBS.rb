module Enocean
  module Esp3
    class FourBS < Radio
      class << self
        def from_data(data, optional_data = [])
          self.new.from_data(data, optional_data)
        end
        
        def rorg
          0xa5
        end
      end
  
      def initialize
        super( [], [])
        self.radio_data = [ 0, 0, 0, 0]
        self.rorg = FourBS.rorg
      end
      
      def build_data
        @data = ([ self.rorg ] + [ self.radio_data ] + self.sender_id + [ self.status ] ).flatten
      end
      
      def from_data(data, optional_data = [])
        self.radio_data = data[1,4]
        self.sender_id = data[5,4]
        self.status = data[-1]
        self
      end
      
      def to_s
        "4BS Packet : " + content
      end
      
      # A5-38-08
      # Speed is 1 == very fast, 0xff very slow, 0 == dimming speed that was set at the actor
      # this was tested with Eltako FUD61NPN dimmer, see Readme
      def dimmer(new_value, speed = 0)
        if new_value > 0
          self.radio_data = [ 0x02 , new_value, speed, 0x09 ]
        else
          self.radio_data = [ 0x02 , new_value, speed, 0x08 ]
        end
      end
      
      def dimmer_teach_in
        self.radio_data = [ 0x02, 0, 0, 0 ]
      end
      
    end
  end
end