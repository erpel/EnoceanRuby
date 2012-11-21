require 'spec_helper'

describe Enocean::Reader do
  
  let(:serial) do
    serial = double("SerialPort")
    serial.stub(:getbyte).and_return(*response)
    serial
  end
  describe "Read base ID response" do
    let(:response) { serialized_packet( [ 0x00, 0x05, 0x00, 0x02 ], [0x02, 0xff, 0x12, 0x13, 0x14 ])}
  
    it "should read a response package" do
      reader = Enocean::Reader.new(serial)
      packet = reader.read_packet
      packet.should_not be_nil
    end
    
    it "should create a read base id response package" do
      reader = Enocean::Reader.new(serial)
      packet = reader.read_packet
      packet.should be_instance_of(Enocean::Esp3::Response)
      packet = packet.as_read_id_response
      packet.base_id.should == [ 0xff, 0x12, 0x13, 0x14 ]
    end
  end
end