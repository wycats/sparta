require "spec_helper"

describe "Function" do
  it "can define functions" do
    e("(function (){ return 3; })").call.should == 3
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

  it "defaults to setting 'this' to the global object" do
    e("x = 47; (function() { return this.x; })()").should == 47
  end

  it "can handle backtraces" do
    begin
      e("x = \nf()")
      raise "flunk"
    rescue Exception => e
      e.awesome_backtrace.find do |loc|
        loc.file == "(javascript)" && loc.line == 2
      end.should be
    end
  end

  it "supports reusing variables across eval" do
    env = Sparta::Environment.new
    env.eval("x = 1")
    env.eval("x").should == 1
  end

  it "raises an exception if called without a function" do
    lambda { e("x = { a: 1 }; x.a()") }.should raise_error(Sparta::Runtime::TypeError)
    lambda { e("x = {}; x.a()") }.should raise_error(Sparta::Runtime::TypeError)
  end

  it "evaluates the function's value only once" do
    e("x = 0; ({ a: (x = x + 1), b: function() { return this.a; }}).b()").should == 1
  end
end
