require "spec_helper"

describe "Arithmetic" do
  it "can add integers" do
    Thrasos.eval("1+1").should == 2
  end
end
