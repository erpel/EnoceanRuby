#!/usr/bin/env ruby

require "./lib/enocean"
require 'serialport'
require 'byebug'


serial_port = "/dev/tty.usbserial-FTVJ62G0"
packet = Enocean::Esp3::ReadIdBase.create

serial = SerialPort.new(serial_port, 57600)
writer = Enocean::Writer.new(serial)
reader = Enocean::Reader.new(serial)
writer.write_packet packet
puts "Starting reading..."
loop do
  begin
    packet = reader.read_packet
    if packet.respond_to? :as_ptm200
      puts "Packet: #{packet.as_ptm200.to_s}"
    end
  rescue => e
    puts "Error #{e.message}"
    puts e.backtrace.join("\n")
  end
  puts packet
end