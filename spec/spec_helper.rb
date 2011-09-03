require "bundler/setup"
require "sparta"
require "pp"

module RSpec::JSHelpers
  dynamic_method :undefined do |g|
    g.push_undef
    g.ret
  end
end

RSpec.configure do
  include RSpec::JSHelpers

  def e(string)
    Sparta::Environment.new.evaluate(string)
  end
end
