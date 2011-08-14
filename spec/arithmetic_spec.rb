require "spec_helper"

describe "Arithmetic" do
  it "can add integers" do
    e("1+1").should == 2
    e("1+1+1").should == 3
  end

  it "can subtract integers" do
    e("3-2").should == 1
    e("5-2-2").should == 1
  end

  it "can add and subtract integers" do
    e("1+2-3+4").should == 4
  end

  it "can multiply and divide integers" do
    e("2*3").should == 6
    e("6/3").should == 2
    e("6/4").should == 1.5
  end

  it "respects order of operations between operators" do
    e("2+4*3-2/1*2").should == 10
    e("(2+4)*(3-2)/1*2").should == 12
  end

  it "can handle unary operators" do
    e("-1").should == -1
    e("-(1+2+3)+3").should == -3
    e("+1").should == 1
    e("+(1+2+3)-3").should == 3
  end
end
