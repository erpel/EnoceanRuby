#!/usr/bin/env ruby
#
# server_1

require 'rubygems'
require 'eventmachine'
require 'sqlite3'
require 'serialport'
require 'json'

require_relative "enocean"

class SocketClient < EM::Connection
  #include EM::Protocols::LineText2


  def initialize(sp)
    @serial = sp
    @jsonLevel = 0
  end

  def self.list
    @list ||= []
  end

  def post_init
    SocketClient.list << self
    @db = SQLite3::Database.new( "database" )

    values = Hash.new
    dimmerStates = Hash.new
    @db.execute("SELECT * FROM DimmerStates") do |row|
      dimmerStates[row[0]] = row[2] #id => value
    end
    values["DimmerStates"] = dimmerStates
    ptm330States = Hash.new
    @db.execute("SELECT * FROM PTM330States") do |row|
      ptm330States[row[0]] = row[1] #id => value
    end
    values["PTM330States"] = ptm330States
    temperatures = Hash.new
    @db.execute("SELECT * FROM Temperatures") do |row|
      temperatures[row[0]] = row[1] #id => value
    end
    values["Temperatures"] = temperatures
    self.send_data "#{values.to_json}\n"

    p "Client connected"

  end

  def unbind
    SocketClient.list.delete self
    @db.close
  end

  def receive_data data
    p data

    jsonArray = []

    data.each_char { |chr| 
      if chr == "{"
        if @jsonLevel == 0
          @buf = ""
        end
        @jsonLevel += 1
        @buf << chr
      elsif chr == "}"
        @jsonLevel -= 1
        @buf << chr
        if @jsonLevel == 0
          cmnd = JSON.parse(@buf)
          spkt = []

          if cmnd["Device"] == "Dimmer"
            if cmnd["Sender"] == "PTM200"
              bathroomRocker = ESP3::Ptm200.new([0xFF, 0xCA, 0xF7, 0x00])
              if cmnd["Action"] == "Up"
                spkt = bathroomRocker.up.serialize
              elsif cmnd["Action"] == "Down"
                spkt = bathroomRocker.down.serialize
              elsif cmnd["Action"] == "Release"
                spkt = bathroomRocker.release.serialize
              end
            elsif cmnd["Sender"] == "Direct"
              bathroomDirect = ESP3::DirectTransfer.new([0xFF, 0xCA, 0xF7, 0x01])
              if cmnd["Action"] == "Dim"
                spkt = bathroomDirect.dim(cmnd["Value"], cmnd["Speed"]).serialize
              elsif cmnd["Action"] == "Off"
                spkt = bathroomDirect.off.serialize
              elsif cmnd["Action"] == "Teach"
                spkt = bathroomDirect.teach.serialize
              end
            end        
          elsif cmnd["Device"] == "Blinds"
            if cmnd["Sender"] == "PTM200"
              blindsRocker = ESP3::Ptm200.new([0xFF, 0xCA, 0xF7, 0x02])
              if cmnd["Action"] == "Up"
                spkt = blindsRocker.up.serialize
              elsif cmnd["Action"] == "Down"
                spkt = blindsRocker.down.serialize
              elsif cmnd["Action"] == "Release"
                spkt = blindsRocker.release.serialize
              end
            end
          end
          #Send with serialport!!
          @serial.puts spkt.pack("C*")
        end
      else
        @buf << chr
      end
    }
    #How do i send via serialport from here??? serial.send_data data
    #bathroomRocker = ESP3::Ptm200.new([0xFF, 0xCA, 0xF7, 0x00])
  end
end



EM.run{
  #@channel = EM::Channel.new
  @serial = SerialPort.new("/dev/ttyUBS0", 57600)
  EM.start_server '0.0.0.0', 8081, SocketClient, @serial

  EM::defer do
    @db = SQLite3::Database.new( "database" )
    loop do 
      byte = @serial.getbyte

      if byte == 0x55

        header = Array.new(4) { |b| b = @serial.getbyte }

        header_crc = @serial.getbyte

        if header_crc == crc8(header)

          data_length = (header[0] << 8) | header[1]
          data = Array.new(data_length) { |b| b = @serial.getbyte }

          optional_data_length = header[2]
          optional_data = Array.new(optional_data_length) { |b| b = @serial.getbyte }

          packet_type = header[3]

          data_crc = @serial.getbyte

          if data_crc == crc8(data + optional_data)
            packet = ESP3::BasePacket.factory(packet_type, data, optional_data)
            p packet
            if packet.class.typeId == 0x01
              begin
               deviceType = 0
               @db.execute("SELECT TypeId FROM Devices WHERE id = ?", packet.senderId) do |row|
                 deviceType = row[0]
               end
               if deviceType == 3
                 state = packet.datadata.first == 0x10 ? 1 : 0
                 @db.execute("UPDATE PTM330States SET Up = ? WHERE Id = ?", state, packet.senderId)
               elsif deviceType == 2
                 if packet.rorg == 0x05
                  state = packet.datadata.first == 0x70 ? 1 : 0
                  @db.execute("UPDATE DimmerStates SET LightsOn = ? WHERE Id = ?", state, packet.senderId)
                  puts "#{packet.senderId}: #{state}"
                elsif packet.rorg == 0xA5
                  value = packet.datadata[1]
                  state = packet.datadata.last == 0x09 ? 1 : 0
                  @db.execute("UPDATE DimmerStates SET LightsOn = ?,DimValue = ? WHERE Id = ?", state, value, packet.senderId)
                  puts "#{packet.senderId}: #{state}, #{value}"
                end
              elsif deviceType == 4
                temp = packet.datadata[2]
                @db.execute("UPDATE Temperatures SET temperature = ? WHERE Id = ?", temp, packet.senderId)

                t = 40.0 - ((40.0 /255.0)*temp)
                p "Temperature is #{t}"

                values = {"Temperatures" => {packet.senderId => temp}}

                SocketClient.list.each{ |c| c.send_data "#{values.to_json}\n" }
              end

            rescue Exception => e
              puts e
            end
          end
        end
      end
    end
  end
  @db.close
end
}
