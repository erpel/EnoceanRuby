module Enocean
  module Esp3

    class FourBS < Radio
      class << self
        def rorg
          0xa5
        end
    
        def from_data(data, optional_data = [])
          self.new.from_data(data, optional_data)
        end
      end
  
      def from_data(data, optional_data)
        @radio_data = data[1,4]
      end
    end
  end
end