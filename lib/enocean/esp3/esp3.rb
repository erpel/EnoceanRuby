
module Enocean
  module Esp3

      class Fourbs < Radio
    
      def self.rorg
          return 0xa5
        end

        def self.from_data(data, sender_id, status, optional_data = [])
        array = [rorg] + data + sender_id + [status]
        return Radio.from_data(array, optional_data)
        end

      end

      class Ptm200

        def initialize(sender_id)
        @sender_id = sender_id
        end

        def up
          return Rps.from_data(0x70, @sender_id, 0x30)
        end
      
        def down
          return Rps.from_data(0x50, @sender_id, 0x30)
        end

        def release
          return Rps.from_data(0x00, @sender_id, 0x20)
        end
      end

      class DirectTransfer

        def initialize(sender_id)
        @sender_id = sender_id
        end

        def dim(value, speed)
          return Fourbs.from_data([0x02, value, speed, 0x09], @sender_id, 0x30)
        end

        def off
        return Fourbs.from_data([0x02, 0x00, 0x00, 0x08], @sender_id, 0x30)
        end
      
        def teach
        return Fourbs.from_data([0x02, 0x00, 0x00, 0x00], @sender_id, 0x30)
        end

      end

      class Gateway

        def initialize(aPort, aBaudrate = 57600, &block)
          @sp = SerialPort.new(aPort, aBaudrate)
          if block_given?
            yield self
            disconnect
          else
            self
          end
        end

        class << self
          alias_method :connect, :new
        end

        def sendPacket(pkt)
          spkt = pkt.serialize
        #Send with serialport!!
        @sp.puts spkt.pack("C*")
      end

      def disconnect
        @sp.close
      end

      def recievePacket
        byte = @sp.getbyte


        if byte == 0x55

          header = Array.new(4) { |b| b = @sp.getbyte }

          header_crc = @sp.getbyte

          if header_crc == crc8(header)

            data_length = (header[0] << 8) | header[1]
            data = Array.new(data_length) { |b| b = @sp.getbyte }

            optional_data_length = header[2]
            optional_data = Array.new(optional_data_length) { |b| b = @sp.getbyte }

            packet_type = header[3]

            data_crc = @sp.getbyte

            if data_crc == crc8(data + optional_data)
              return BasePacket.factory(packet_type, data, optional_data)
            end
          end
        end
      
      end

      def startRadioReciever(queues)
        rt = Thread.new do
          loop { 
            pkt = self.recievePacket

            if pkt
              begin
                # try to get queue for packet
                queues[pkt.class.type_id] << pkt
                puts 'Packet on specific queue'
              rescue
                queues['default'] << pkt
                puts 'Packet on default queue'
              end
            end
          }
        end

        return rt
      end

    end
  end
end