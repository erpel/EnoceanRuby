require 'spec_helper'

describe Enocean::Esp3::CommonCommand do
  describe "ReadIdBase" do
    let(:command) { Enocean::Esp3::ReadIdBase.create }
    it "should create a ReadId command" do
      expect(command.packet_type).to eq(0x05)
    end
    
    it "should print the packet " do
      expect(command.to_s).to_not be_nil
    end
    
    describe "response" do
      let(:response) { Enocean::Esp3::Response.from_data([0x0, 0xff, 0x0, 0x1, 0x2]).as_read_id_response }
      it "should parse the correct response " do
        response.should be_ok
        expect(response.base_id).to eq([0xff, 0x0, 0x1, 0x2])
      end
    end
  end
end