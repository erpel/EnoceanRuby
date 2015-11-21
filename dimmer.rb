#!/usr/bin/env ruby

require "./lib/enocean"
require 'serialport'
require 'byebug'

# Example for a dimmer telegram for the FUD61NPN Eltako aktor
# Information on the dimmer telegram was taken out of
# http://www.eltako.com/fileadmin/downloads/en/_catalogue/wireless_system_chapterT_high_res.pdf
class Dimmer
  def initialize(writer, sender_id)
    @writer , @sender_id = writer, sender_id
  end
  
  def teach
    teach_packet = Enocean::Esp3::FourBS.new
    teach_packet.sender_id = @sender_id
    teach_packet.dimmer_teach_in
    teach_packet.build_data
    @writer.write_packet(teach_packet)
  end
  def set(value, speed = 0)
    dimm_packet = Enocean::Esp3::FourBS.new
    dimm_packet.sender_id = @sender_id
    dimm_packet.dimmer(value, speed)
    dimm_packet.build_data
    @writer.write_packet(dimm_packet)
  end
end



serial_port = "/dev/tty.usbserial-FTVJ62G0"
serial = SerialPort.new(serial_port, 57600)
writer = Enocean::Writer.new(serial)
reader = Enocean::Reader.new(serial)

dimmer = Dimmer.new(writer, [ 0xFF, 0xFC, 0x01, 0x82 ])
debugger
puts "Finished"


