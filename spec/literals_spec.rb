require "spec_helper"

describe "primitive literals" do
  it "understands numbers" do
    e("1").should == 1
    e("1000").should == 1000
    e("1.5").should == 1.5
  end

  it "understands strings" do
    e(%{"hi"}).should == "hi"
    e(%{'hi'}).should == "hi"
    e(%{"hi\nhi"}).should == "hi\nhi"
  end

  it "understands booleans" do
    e("true").should == true
    e("false").should == false
  end

  it "understands null" do
    e("null").should == nil
  end

  it "understands undefined" do
    e("x = undefined; x").should == undefined
  end
end
