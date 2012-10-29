module Enocean
  class Writer
    def initialize(serial)
      @serial = serial
    end
    
    def write_packet(packet)
      @serial.puts packet.serialize.pack("C*")
    end
  end
end