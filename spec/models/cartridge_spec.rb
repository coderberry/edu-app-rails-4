require 'spec_helper'

describe Cartridge do
  it "#generate_uid" do
    cartridge = Cartridge.new
    cartridge.send(:generate_uid)
    cartridge.uid.should match /\S{16}/
  end
end
