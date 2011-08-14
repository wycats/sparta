require "spec_helper"

describe "Assignment" do
  def e(string)
    Thrasos.eval(string)
  end

  it "can handle simple assignment" do
    e("x = 3; x").should == 3
  end
end

