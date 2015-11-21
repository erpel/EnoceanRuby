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
        @data = ([ self.rorg ] + [ self.radio_data ] + self.sender_id + [ flags[:t21] >> 5 | @flags[:nu] >> 4 ]).flatten
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
    end
  end
end