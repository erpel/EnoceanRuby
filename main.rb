#!/usr/bin/env ruby
#
# server_1

require 'rubygems'
require 'eventmachine'
require 'sqlite3'
require 'serialport'
require 'json'

require_relative "enocean"

module SocketClient
  def self.list
    @list ||= []
  end

  def post_init
    SocketClient.list << self
    @db = SQLite3::Database.new( "database" )

    values = []
    @db.execute("SELECT * FROM Devices") do |row|
      values << {row[0] => row[1]} #id => value
    end
    self.send_data "#{values.to_json}\n"

    p "Client connected"

  end

  def unbind
    SocketClient.list.delete self
    @db.close
  end

  def receive_data data
    p data
    #How do i send via serialport from here??? serial.send_data data
    $serial.send_data data
  end
end

db = SQLite3::Database.new( "database" )
$serial = SerialPort.new("/dev/tty.usbserial-FTVBI8RQ", 57600)

Thread.new do
  loop { 
    byte = $serial.getbyte


      if byte == 0x55

        header = Array.new(4) { |b| b = $serial.getbyte }

        header_crc = $serial.getbyte

        if header_crc == crc8(header)

          data_length = (header[0] << 8) | header[1]
          data = Array.new(data_length) { |b| b = $serial.getbyte }

          optional_data_length = header[2]
          optional_data = Array.new(optional_data_length) { |b| b = $serial.getbyte }

          packet_type = header[3]

          data_crc = $serial.getbyte

          if data_crc == crc8(data + optional_data)
            packet = ESP3::BasePacket.factory(packet_type, data, optional_data)
          end
        end
      end
  }
end
#readstate = 0
#buffer = Hash.new

EM.run{
  EM.start_server '0.0.0.0', 8081, SocketClient
=begin
  $serial = EM.open_serial '/dev/tty.usbserial-FTVBI8RQ', 57600, 8, 1, 0

  $serial.on_data do |data|
    #Parse data into an array called values
    #db.execute("UPDATE values SET value = ? WHERE id = ?", values["value"], values["id"])

    data.each_byte { |byte|  
          if (readstate == 0) && (byte == 0x55)
            #Got Sync Byte
            readstate = 1
            next

          elsif readstate == 1
            buffer["highDataLength"] = byte
            readstate = 2
            next

          elsif readstate == 2
            buffer["lowDataLength"] = byte
            buffer["dataLength"] = (buffer["highDataLength"] << 8) | buffer["lowDataLength"]
            readstate = 3
            next

          elsif readstate == 3
            buffer["optionalLength"] = byte
            readstate = 4
            next

          elsif readstate == 4
            buffer["packetType"] = byte
            readstate = 5
            next

          elsif readstate == 5
            if byte == crc8([buffer["highDataLength"], buffer["lowDataLength"], buffer["optionalLength"], buffer["packetType"]])
              readstate = 6
            else
              readstate = 0
              buffer.clear
            end
            next

          elsif readstate == 6


          end
        }

        if data.getbyte(0) == 0x55
          crc = data.getbyte(5)
          header = data.unpack("xnCC")
          if crc == crc8(header)
            dataLength, optionalLength, packetType = header
            msgData = data.unpack("x6C#{dataLength}") #[6..6+dataLength].unpack("sC*")
            msgOptional = data.unpack("x#{6+dataLength}C#{optionalLength}")#data[7+dataLength..7+dataLength+optionalLength].unpack("C*")
            crc = data.getbyte(6+dataLength+optionalLength)
            if crc == crc8(msgData+msgOptional)
              packet = ESP3::BasePacket.factory(packetType, msgData, msgOptional)
              p packet.senderId
              begin
               deviceType = 0
               db.execute("SELECT TypeId FROM Devices WHERE id = ?", packet.senderId) do |row|
                 deviceType = row[0]
               end
               if deviceType == 3
                 state = packet.datadata.first == 0x10 ? 1 : 0
                 db.execute("UPDATE PTM330States SET Up = ? WHERE Id = ?", state,packet.senderId)
               elsif deviceType == 2
                 if packet.rorg == 0x05
                  state = packet.datadata.first == 0x70 ? 1 : 0
                  db.execute("UPDATE DimmerStates SET LightsOn = ? WHERE Id = ?", state, packet.senderId)
                  puts "#{packet.senderId}: #{state}"
                elsif packet.rorg == 0xA5
                  value = packet.datadata[1]
                  state = packet.datadata.last == 0x09 ? 1 : 0
                  db.execute("UPDATE DimmerStates SET LightsOn = ?,DimValue = ?  WHERE Id = ?", state, value,packet.senderId)
                  puts "#{packet.senderId}: #{state}, #{value}"
                end
              end

            rescue Exception => e
             puts e
           end
         end

       end
     end

     SocketClient.list.each{ |c| c.send_data "#{data}\n" }
   end
=end
}

 db.close