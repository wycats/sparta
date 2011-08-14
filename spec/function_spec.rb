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
end
