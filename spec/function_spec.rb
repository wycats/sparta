require "spec_helper"

describe "Function" do
  def e(string)
    Thrasos.eval(string)
  end

  it "can define and call functions" do
    e("(function (){ return 3; })();").should == 3
  end
end
