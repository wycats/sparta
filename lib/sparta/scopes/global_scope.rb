require "sparta/scopes/scope"

module Sparta
  module Scopes
    class GlobalScope < Scope
      def initialize(generator)
        super(generator, nil)
      end

      def push_variable(name, current_depth = 0, g = self.g)
        g.push_ivar :@window
        g.push_literal name
        g.send :spec_Get, 1
      end

      def set_variable(name, current_depth = 0, g = self.g)
        g.push_literal name
        g.push_ivar :@window
        g.rotate 3
        g.send :internal_Put, 2
      end
      alias set_local set_variable
    end
  end
end
