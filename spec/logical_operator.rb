require "spec_helper"

bools = {
  "undefined" => false,
  "null" => false,
  "false" => false,
  "true" => true,
  "''" => false,
  "'foo'" => true,
  "0" => false,
  "0.0" => false,
  "0.5" => true,
  "10" => true,
  "({})" => true,
  "([])" => true
}

describe "logical not" do
  bools.each do |value, to_bool|
    it "should return #{!to_bool} for !#{value}" do
      e("!#{value}").should == !to_bool
    end

    it "should return #{to_bool} for !!#{value}" do
      e("!!#{value}").should == to_bool
    end
  end
end

describe "strict equals" do
  bools.each do |value, to_bool|
    it "#{value} should be equal itself" do
      e("x = #{value}; x === x").should == true
    end
  end
end

describe "logical or" do
  bools.each do |value, to_bool|
    if to_bool
      it "should return the left hand side of `#{value}` || 100" do
        e("x = #{value}; y = x || 100; x === y").should == true
      end
    else
      it "should return the right hand side of `#{value}` || 100" do
        e("x = #{value}; y = x || 100; z = y === 100; z").should == true
      end
    end
  end
end

describe "logical and" do
  bools.each do |value, to_bool|
    if to_bool
      it "should return the right hand side of `#{value}` && 100" do
        e("x = #{value}; y = x && 100; z = y === 100; z; ").should == true
      end
    else
      it "should return the right hand side of `#{value}` && 100" do
        e("x = #{value}; y = x && 100; y === x").should == true
      end
    end
  end
end

