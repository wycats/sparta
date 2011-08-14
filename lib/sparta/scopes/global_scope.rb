require "sparta/scopes/scope"

module Sparta
  module Scopes
    class GlobalScope < Scope
      def initialize(generator)
        super(generator, nil)
      end

      def depth_for(name, depth = 0)
        [self, depth]
      end
    end
  end
end