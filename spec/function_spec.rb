require "spec_helper"

describe "Function" do
  def e(string)
    Thrasos.eval(string)
  end

  it "can define and call functions" do
    e("(function (){ return 3; })();").should == 3
  end

  it "can access outer binding" do
    e("x = 1; y = 2; (function (){ return x + y; })();").should == 3
    e("x = 1; y = 2; (function (){ z = x + y; })(); z").should == 3
  end

  it "can set local variables" do
    e("x = 1; y = 2; (function (){ return x + y; })();").should == 3
    e("x = 1; y = 2; (function (){ var x = 5; z = x + y; })(); x + y + z").should == 10
  end

  it "can assign functions to a variable" do
    e("x = function() { return 7; }; y = 4; x() + y").should == 11
  end

  it "can accept arguments" do
    e("(function(x) { return x; })(47)").should == 47
    e("(function(x, y) { return x + y; })(45, 2)").should == 47
    e("var x = 1; (function(x, y) { return x + y; })(45, 2) + x").should == 48
  end
end
