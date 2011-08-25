require "spec_helper"

describe "Objects" do
  it "creates a simple object" do
    e("x = { a: 1 }; x.a").should == 1
    e("x = { a: { b: 2 }, c: 5 }; x.a.b + x.c").should == 7
  end

  it "creates a new object with the new operator" do
    e("x = function() {}; y = new x; y.a = 1; y.a").should == 1
    e("x = function() {}; x.prototype = { a: 1 }; y = new x; y.b = 2; y.a + y.b").should == 3
    e("x = function() { this.c = 5; }; x.prototype = { a: 1 }; y = new x; y.b = 2; y.a + y.b + y.c").should == 8
  end
end
