require "spec_helper"

describe "Object.prototype.toString" do
  it "returns [object Object] for objects" do
    e("({}).toString()").should == "[object Object]"
  end

  map = {
    "undefined" => "Undefined",
    "null" => "Null",
    "true" => "Boolean",
    "false" => "Boolean",
    "[]" => "Array",
    "(function() {})" => "Function",
    "123" => "Number",
    "12.3" => "Number",
    "({})" => "Object",
    "'string'" => "String"
  }

  map.each do |value, klass|
    it "returns [object #{klass}] when `call'ed with #{value}" do
      e("Object.prototype.toString.call(#{value})").should == "[object #{klass}]"
    end
  end
end
