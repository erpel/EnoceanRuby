require 'spec_helper'

include Enocean::Esp3

describe Enocean::Esp3::Rps do
  
  describe Enocean::Esp3::PTM200 do
    let(:sender_id)  { [ 0xff, 0xee, 0xdd, 0xcc ] }
    let(:rorg) { [ 0xf6 ] }
    let(:radio_data) do
      rorg + [ 0x00 ] + sender_id + [ 0x00 ]
    end
    
    let(:a0_pressed_data) do
      radio_data[1] = 0b00100000
      radio_data
    end
    
    
    it "should create a valid PTM200 package out of radio data" do
      packet = PTM200.from_data(a0_pressed_data, [])
      packet.should_not be_nil
      packet.action1.should == :a0
      packet.to_s.should_not be_nil
    end
    
    it "should create a valid PTM200 package via the factory from the data" do
      packet = PacketFactory.from_data(Radio.packet_type, a0_pressed_data, [])
      packet.should be_instance_of(Rps)
      packet = PTM200.from_packet(packet)
      packet.should be_instance_of(PTM200)
    end
    
    it "should construct a PTM200 package " do
      pending "Constructing a PTM200 package"
      packet = Enocean::Esp3::Radio.from_data( [ 0x00 ] )
    end
    
  end
end