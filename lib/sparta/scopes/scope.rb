module Sparta
  module Scopes
    class Scope
      attr_reader :variables, :generator
      alias g generator

      def initialize(generator, parent)
        @parent    = parent
        @variables = []
        @generator = generator
      end

      def depth_for(name, depth=0)
        if existing = @variables.index(name)
          [self, depth]
        else
          @parent.depth_for(name, depth + 1)
        end
      end

      def slot_for(name)
        if existing = @variables.index(name)
          existing
        else
          @variables << name
          @variables.size - 1
        end
      end

      def set_local(name)
        g.set_local slot_for(name)
      end

      def set_variable(name)
        scope, depth = depth_for(name)

        if depth == 0
          scope.set_local name
        else
          g.set_local_depth depth, scope.slot_for(name)
        end
      end

      def push_variable(name)
        scope, depth = depth_for(name)

        if depth == 0
          g.push_local slot_for(name)
        else
          g.push_local_depth depth, scope.slot_for(name)
        end
      end
    end
  end
end