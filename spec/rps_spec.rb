require 'spec_helper'

include Enocean::Esp3

describe Enocean::Esp3::Rps do

  let(:sender_id)  { [ 0xff, 0xee, 0xdd, 0xcc ] }
  let(:rorg) { [ 0xf6 ] }
  let(:radio_data) do
    rorg + [ 0x00 ] + sender_id + [ 0x00 ]
  end
  
  let(:a0_pressed_data) do
    radio_data[1] = 0b00100000
    radio_data
  end
  
  let(:everything_released) do 
    radio_data[1] = 0b00000000
    radio_data
  end
  
  it "should print the packages"do
    packet = Rps.from_data(everything_released)
    packet.to_s
    packet = Rps.from_data(a0_pressed_data)
    packet.to_s
  end
  
  it "should create a valid PTM200 package out of radio data" do
    packet = Rps.from_data(a0_pressed_data, [])
    packet.should_not be_nil
    packet.action1.should == :a0
    packet.to_s.should_not be_nil
  end
  
  it "should create a valid PTM200 package via the factory from the data" do
    packet = PacketFactory.from_data(Radio.packet_type, a0_pressed_data, [])
    packet.should be_instance_of(Rps)
  end
  
  it "should construct a PTM200 package " do
    pending "Constructing a PTM200 package"
    packet = Enocean::Esp3::Radio.from_data( [ 0x00 ] )
    packet.should_not be_nil
  end
  
  it "should be able to create a packet from scratch " do
    packet = Enocean::Esp3::Rps.new
    packet.action1 = :b1
    packet.build_data
    expect(packet.radio_data.size).to eq(1)
    packet.radio_data.first.should == 0b01010000
    packet.serialize
  end
  
  it "should be able to create a released packet" do 
    packet = Enocean::Esp3::Rps.new
    packet.build_data
    expect(packet.radio_data.size).to eq(1)
    packet.radio_data.first.should == 0
    packet.serialize
  end
end