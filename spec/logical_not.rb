require "spec_helper"

describe "logical not" do
  map = {
    "undefined" => true,
    "null" => true,
    "false" => true,
    "true" => false,
    "''" => true,
    "'foo'" => false,
    "0" => true,
    "0.0" => true,
    "10" => false,
    "({})" => false,
    "([])" => false
  }

  map.each do |value, not_val|
    it "should return #{not_val} for !#{value}" do
      e("!#{value}").should == not_val
    end

    it "should return #{!not_val} for !!#{value}" do
      e("!!#{value}").should == !not_val
    end
  end
end
