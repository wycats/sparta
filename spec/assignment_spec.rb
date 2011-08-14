require "spec_helper"

describe "Assignment" do
  it "can handle simple assignment" do
    e("x = 3; x").should == 3
  end

  it "can handle chained assignment" do
    e("x = y = 3; x + y").should == 6
  end
end

