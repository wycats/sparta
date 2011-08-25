require "sparta/compilers/compiler"
require "sparta/scopes/global_scope"

module Sparta
  module Compilers
    class EvalCompiler < Compiler
      def initialize(static_scope = nil)
        @generator = Rubinius::Generator.new
        @scope = Sparta::Scopes::GlobalScope.new(@generator)
        @static_scope = static_scope
      end

      # Automatically return the last expression unless
      # the last expression has no value. In this case,
      # it will return undefined.
      def visit_SourceElementsNode(o)
        last_expr = o.value.last
        if last_expr && !no_value_node?(last_expr.value)
          last_expr.value = ReturnNode.new(last_expr.value)
        end
        super
      end
    end
  end
end
