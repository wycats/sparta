require "spec_helper"

describe "typeof operator" do
  it "returns 'undefined' for undefined values" do
    e("typeof undefined").should == "undefined"
    e("typeof noSuchValueHere").should == "undefined"
    e("x = undefined; typeof x").should == "undefined"
    e("x = {}; typeof x.y").should == "undefined"
    e("var x; typeof x.y").should == "undefined"
  end

  map = {
    "null" => "object",
    "true" => "boolean",
    "false" => "boolean",
    "'string'" => "string",
    "(function() {})" => "function",
    "{}" => "object"
  }

  map.each do |value, type|
    it "returns '#{type}' for #{value} values" do
      e("typeof #{value}").should == type
      e("x = #{value}; typeof x").should == type
      e("x = { y: #{value} }; typeof x.y").should == type
    end
  end
end
