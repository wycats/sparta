require "bundler/setup"
require "sparta"
require "pp"

RSpec.configure do
  def e(string)
    Sparta::Environment.new.evaluate(string)
  end
end
