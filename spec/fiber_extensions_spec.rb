$:.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')
require 'neverblock'

describe Fiber do
  before(:all) do
    @fiber = Fiber.new {puts "I'm a new fiber"}
  end

  it "should be able to set fiber local variable" do
    @fiber[:x] = "wow"
  end

  it "should be able to retrieve an already set fiber local variable" do
    @fiber[:x].should == "wow"
  end

  it "should return nil when trying to retrieve an unset fiber local variable" do
    @fiber[:y].should == nil
  end

  after(:all) do
    @fiber = nil
  end
end
