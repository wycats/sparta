require "spec_helper"

describe "Objects" do
  it "creates a simple object" do
    e("x = { a: 1 }; x.a").should == 1
    e("x = { a: { b: 2 }, c: 5 }; x.a.b + x.c").should == 7
  end
end
