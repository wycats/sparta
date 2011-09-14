require "spec_helper"

describe "if" do
  it "should not execute the conditional branch if the condition is false" do
    e("var x = false, y = false; if(x) { y = true; } y").should == false
    e("var x = 0, y = false; if(x) { y = true; } y").should == false
    e("var x = '', y = false; if(x) { y = true; } y").should == false
    e("var x = null, y = false; if(x) { y = true; } y").should == false
    e("var x, y = false; if(x) { y = true; } y").should == false
  end

  it "should execute the conditional branch if the condition is true" do
    e("var x = true, y = false; if(x) { y = true; } y").should == true
    e("var x = 1, y = false; if(x) { y = true; } y").should == true
    e("var x = 'hi', y = false; if(x) { y = true; } y").should == true
    e("var x = {}, y = false; if(x) { y = true; } y").should == true
  end

  it "should execute the else branch if the condition is false" do
    e("var x = false, y = false; if(x) { y = 'if'; } else { y = 'else'; } y").should == 'else'
    e("var x = 0, y = false; if(x) { y = 'if'; } else { y = 'else'; } y").should == 'else'
    e("var x = '', y = false; if(x) { y = 'if'; } else { y = 'else'; } y").should == 'else'
    e("var x = null, y = false; if(x) { y = 'if'; } else { y = 'else'; } y").should == 'else'
    e("var x, y = false; if(x) { y = 'if'; } else { y = 'else'; } y").should == 'else'
  end

  it "should execute the if branch if the condition is true" do
    e("var x = true, y = false; if(x) { y = 'if'; } else { y = 'else'; } y").should == 'if'
    e("var x = 1, y = false; if(x) { y = 'if'; } else { y = 'else'; } y").should == 'if'
    e("var x = 'hi', y = false; if(x) { y = 'if'; } else { y = 'else'; } y").should == 'if'
    e("var x = {}, y = false; if(x) { y = 'if'; } else { y = 'else'; } y").should == 'if'
  end
end

