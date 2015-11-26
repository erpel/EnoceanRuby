#!/usr/bin/env ruby

require "./lib/enocean"
require 'serialport'
require 'byebug'
require "./config"

packet = Enocean::Esp3::ReadIdBase.create

serial = SerialPort.new(@serial_port, 57600)
writer = Enocean::Writer.new(serial)
reader = Enocean::Reader.new(serial)
writer.write_packet packet
base_id = reader.read_packet.as_read_id_response.base_id
puts "BaseID of TM300 is #{base_id.collect { |s| s.to_s(16)}.join(":")}"
puts "Starting reading..."
loop do
  begin
    packet = reader.read_packet
  rescue => e
    puts "Error #{e.message}"
    puts e.backtrace.join("\n")
  end
  puts packet
end
