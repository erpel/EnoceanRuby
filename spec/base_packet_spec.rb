require 'spec_helper'

describe Enocean::Esp3::BasePacket do
  let(:packet) { Enocean::Esp3::PacketFactory.from_data(0x9, [ 0x8 ], [ 0x9 ]) }

  it "should serialze the packet correctly" do
    expect(packet.serialize).to eq([ 0x55, 0x00, 0x01, 0x01, 0x9, 0x41, 0x8, 0x9, 0x97 ])
  end
  
  it "should be able to print the packet" do
    expect(packet.to_s).to_not be_nil
  end
end