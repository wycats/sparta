require "sparta/scopes/scope"

module Sparta
  module Scopes
    class GlobalScope < Scope
      def initialize(generator)
        super(generator, nil)
      end

      def push_variable(name, current_depth = 0, g = self.g)
        g.push_const :JS_WINDOW
        g.push_literal name
        g.send :get, 1
      end

      def set_variable(name, current_depth = 0, g = self.g)
        g.push_literal name
        g.push_const :JS_WINDOW
        g.rotate 3
        g.send :put, 2
      end
      alias set_local set_variable
    end
  end
end
