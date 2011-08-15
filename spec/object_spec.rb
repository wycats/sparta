require "spec_helper"

describe "Objects" do
  it "creates a simple object" do
    e("x = { a: 1 }; x.a").should == 1
  end
end
