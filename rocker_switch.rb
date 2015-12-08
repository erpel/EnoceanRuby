#!/usr/bin/env ruby

require "./lib/enocean"
require 'serialport'
require 'byebug'
require './config'

@switch_address = [ 0xff, 0xab, 0xf7, 0x83 ]

# Example for a PTM200 switch running a FUD61NPN Eltako aktor
# Using Enocean F6-02-01 protocol
# "ON" telegrams are of the first variant:  3 bits which button was pressed, and then the 4th bit set to 1
# the off telegrams are of the second variant: first 3 bits how many buttons are pressed, then 0
# there is no teach in mode for PTM200, just put the dimmer into teach mode and run "on"
class Switch
  def initialize(writer, sender_id)
    @writer = writer
    @b1_on = Enocean::Esp3::Rps.new
    @b1_on.sender_id = sender_id
    @b1_on.action1 = :b1
    @b1_on.build_data

    @b1_off = Enocean::Esp3::Rps.new
    @b1_off.sender_id = sender_id
    @b1_off.build_data

    @b0_on = Enocean::Esp3::Rps.new
    @b0_on.sender_id = sender_id
    @b0_on.action1 = :b0
    @b0_on.build_data

    @b0_off = Enocean::Esp3::Rps.new
    @b0_off.sender_id = sender_id
    @b0_off.build_data
  end

  def on
    increase(0.2)
  end
  
  def off
    decrease(0.2)
  end
  
  def up_press
    @writer.write_packet(@b0_on)
  end
  
  def release_all
    @writer.write_packet(@b0_off)
  end

  def increase(time)
    @writer.write_packet(@b0_on)
    sleep(time)
    @writer.write_packet(@b0_off)
  end
  def decrease(time)
    @writer.write_packet(@b1_on)
    sleep(time)
    @writer.write_packet(@b1_off)
  end
end



serial = SerialPort.new(@serial_port, 57600)
writer = Enocean::Writer.new(serial)
reader = Enocean::Reader.new(serial)

switch = Switch.new(writer, @switch_address) 
debugger
puts "Finished"


