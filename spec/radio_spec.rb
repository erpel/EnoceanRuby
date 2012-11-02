require 'spec_helper'

describe Enocean::Esp3::Radio do
  
  describe Enocean::Esp3::PTM200 do
    let(:radio_packet) do
      radio = double("Enocean::Esp3::Radio")
      radio.stub!(:sender_id) { 0xffeeddcc }
      radio.stub!(:flags) { { :nu => 1, :t21 => 1 } }
      radio.stub!(:radio_data) { [ 0b00100000 ] }
      radio.stub!(:rorg) { 0xf6 }
      radio
    end
    
    it "should create a valid PTM200 package" do
      packet = Enocean::Esp3::Rps.factory(radio_packet)
      packet.should_not be_nil
      packet.action1.should == :a0
      packet.to_s.should_not be_nil
    end
  end
end