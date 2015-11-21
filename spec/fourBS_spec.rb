require 'spec_helper'
require 'byebug'

include Enocean::Esp3

describe Enocean::Esp3::FourBS do

  let(:sender_id)  { [ 0xff, 0xee, 0xdd, 0xcc ] }
  let(:rorg) { [ 0xa5 ] }
  let(:radio_data) do
    rorg + [ 0x02, 0x00, 0x00, 0x00 ] + sender_id + [ 0x00 ]
  end
  
  let(:teach_in) do
    radio_data
  end
  
  it "should print the packages"do
    packet = FourBS.from_data(teach_in)
    packet.to_s
  end
  
  it "should create a valid PTM200 package out of radio data" do
    packet = FourBS.from_data(teach_in, [])
    packet.should_not be_nil
    packet.to_s.should_not be_nil
  end
  
  it "should create a valid PTM200 package via the factory from the data" do
    packet = PacketFactory.from_data(Radio.packet_type, teach_in, [])
    packet.should be_instance_of(FourBS)
  end
end