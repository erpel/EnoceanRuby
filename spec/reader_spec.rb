require 'spec_helper'

describe Enocean::Reader do
  
  let(:serial) do
    serial = double("SerialPort")
    serial.stub(:getbyte).and_return(*response)
    serial
  end
  describe "Read base ID response" do
    let(:response) { serialized_packet( [ 0x00, 0x05, 0x00, 0x05 ], [0x02, 0xff, 0x12, 0x13, 0x14 ])}
  
    it "should read a response package" do
      reader = Enocean::Reader.new(serial)
      packet = reader.read_packet
      packet.should_not be_nil
    end
    
    it "should create a read base id response package" do
      reader = Enocean::Reader.new(serial)
      packet = reader.read_packet
      packet = Enocean::Esp3::ReadIdBaseResponse.from_packet(packet)
      packet.base_id.should == [ 0xff, 0x12, 0x13, 0x14 ]
    end
  end
end