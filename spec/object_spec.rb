require "spec_helper"

describe "Object Literals" do
  it "creates a simple object" do
    e("x = { a: 1 }; x.a").should == 1
    e("x = { a: { b: 2 }, c: 5 }; x.a.b + x.c").should == 7
    e(<<-JS).should == 35
      x = { '0': 10, '1': 20, a: 5 };
      x[0] + x['1'] + x['a'];
    JS
  end

  it "creates a new object with the new operator" do
    e("x = function() {}; y = new x; y.a = 1; y.a").should == 1
    e("x = function() {}; x.prototype = { a: 1 }; y = new x; y.b = 2; y.a + y.b").should == 3
    e("x = function() { this.c = 5; }; x.prototype = { a: 1 }; y = new x; y.b = 2; y.a + y.b + y.c").should == 8
  end

  describe "foo in bar" do
    it "should return true if the object hasOwnProperty of the key" do
      e("x = { a: 1 }; 'a' in x").should == true
      e("x = { a: 1 }; 'b' in x").should == false
    end

    it "should return true if the property exists on the prototype" do
      e("x = function() {}; x.prototype = { a: 1 }; 'a' in new x").should == true
      e("x = function() {}; x.prototype = { a: 1 }; 'b' in new x").should == false
    end
  end

  describe "hasOwnProperty" do
    it "should return true if the object hasOwnProperty" do
      e("x = { a: 1 }; x.hasOwnProperty('a')").should == true
      e("x = { a: 1 }; x.hasOwnProperty('b')").should == false
    end

    it "should return false if the object has the property only on its prototype" do
      e("x = function() {}; x.prototype = { a: 1 }; y = new x; y.hasOwnProperty('a')").should == false
    end
  end

  describe "delete key" do
    it "should delete the key if it exists on the object" do
      e("x = { a: 1 }; delete x.a; x.a").should == undefined
      e("x = { a: 1 }; delete x['a']; x.a").should == undefined
      e("x = { a: 1 }; y = 'a'; delete x[y]; x.a").should == undefined
    end

    it "should not delete the key if it only exists on the prototype" do
      e("x = function() {}; x.prototype = { a: 1 }; y = new x; delete y.a; y.a").should == 1
    end
  end
end

describe "Array Literals" do
  it "creates a simple Array" do
    e("x = [1,2,3]").to_a.should == [1,2,3]
    e("x = [1,2,3]; x[1]").should == 2
    e("x = [1,2,3]; x[5]").should == undefined
  end
end
