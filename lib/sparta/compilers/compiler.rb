require "sparta/scopes/scope"

module Sparta
  module Compilers
    class Compiler < RKelly::Visitors::Visitor
      include RKelly::Nodes

      attr_reader :generator, :scope
      alias g generator
      alias s scope

      def initialize(parent)
        @generator = Rubinius::Generator.new
        @scope = Sparta::Scopes::Scope.new(@generator, parent.scope)
      end

      # Receives the AST and returns a Rubinius::CompiledMethod.
      def compile(ast)
        accept ast
        debug if ENV["DEBUG_COMPILER"]
        finalize
        rbx_compiler = Rubinius::Compiler.new :encoded_bytecode, :compiled_method
        rbx_compiler.encoder.input generator
        rbx_compiler.run
      end

      def visit_SourceElementsNode(o)
        last_expr = o.value.last

        # Push a ReturnNode to the compiler if we don't have one yet.
        # TODO We are returning 0 right now, but this needs to be changed to undefined.
        # TODO Don't modify the tree inside the compiler, we need an ASTWalker to figure this out.
        if !last_expr || !last_expr.value.is_a?(ReturnNode)
          o.value <<
            ExpressionStatementNode.new(
              ReturnNode.new(
                NumberNode.new(0)
              )
            )
        end

        o.value.each { |x| x.accept(self) }
      end

      def visit_VarDeclNode(o)
        o.value.accept(self)
        s.set_local o.name
      end

      def visit_FunctionExprNode(o)
        set_line(o)
        body = o.function_body.value

        # Get a new compiler
        block = Compiler.new(self)

        # Configures the new generator
        # TODO Move this to a method on the compiler
        block.generator.for_block = true
        block.generator.total_args = o.arguments.size
        block.generator.cast_for_multi_block_arg unless o.arguments.empty?

        # Visit arguments and then the block
        o.arguments.each { |x| x.accept(block) }
        block.accept(body)

        # Invoke the create block instruction
        # with the generator of the block compiler
        g.create_block block.finalize
      end

      def visit_ParameterNode(o)
        set_line(o)
        g.shift_array
        s.set_local o.value
        g.pop
      end

      def visit_FunctionCallNode(o)
        o.value.accept(self)
        set_line(o)
        arguments = o.arguments.value
        arguments.each { |x| x.accept(self) }
        g.send :call, arguments.size
      end

      def visit_ReturnNode(o)
        o.value.accept(self)
        g.ret
      end

      def visit_ExpressionStatementNode(o)
        o.value.accept(self)
        # At the end of each expression we pop the value out of the stack.
        # Except if the node is an specific node that do not push items
        # to the stack (for example return, break and friends).
        g.pop unless no_value_node?(o.value)
      end

      def visit_AddNode(o)
        o.left.accept(self)
        set_line(o)
        o.value.accept(self)
        g.meta_send_op_plus g.find_literal(:+)
      end

      def visit_SubtractNode(o)
        o.left.accept(self)
        set_line(o)
        o.value.accept(self)
        g.meta_send_op_minus g.find_literal(:-)
      end

      def visit_MultiplyNode(o)
        o.left.accept(self)
        set_line(o)
        o.value.accept(self)
        g.send :*, 1
      end

      def visit_DivideNode(o)
        o.left.accept(self)
        set_line(o)
        g.send :to_f, 0
        o.value.accept(self)
        g.send :/, 1
      end

      def visit_UnaryPlusNode(o)
        o.value.accept(self)
      end

      def visit_UnaryMinusNode(o)
        set_line(o)
        value = o.value

        # If the underlying node is a number value
        # we can calculate the unary on Ruby land. Yay!
        if value.is_a?(NumberNode)
          g.push_int(-1 * value.value)
        else
          value.accept(self)
          g.push_int -1
          g.send :*, 1
        end
      end

      def visit_NumberNode(o)
        set_line(o)
        g.push_int o.value
      end

      def visit_OpEqualNode(o)
        o.value.accept(self)
        set_line(o)
        s.set_variable o.left.value
      end

      def visit_ResolveNode(o)
        set_line(o)
        s.push_variable o.value
      end

      def visit_DotAccessorNode(o)
        super
        set_line(o)
        g.push_literal o.accessor.to_sym
        g.send :spec_Get, 1
      end

      def visit_ObjectLiteralNode(o)
        set_line(o)
        g.push_const :LiteralObject
        g.send :allocate, 0
        super
      end

      def visit_PropertyNode(o)
        set_line(o)
        g.push_literal o.name.to_sym
        super
        g.send :internal_LiteralPut, 2
      end

      protected

      def set_line(o)
        g.set_line o.line if o.line
      end

      # Finalizes configuring the generator and returns it.
      def finalize
        g.local_names = s.variables
        g.local_count = s.variables.size
        g
      end

      def debug
        ip = 0
        puts
        while instruction = g.stream[ip]
          instruct = Rubinius::InstructionSet[instruction]
          ip += instruct.size
          puts instruct.name
        end
      end

      # Nodes that do not push value to the stack.
      # For example return, break and friends.
      def no_value_node?(o)
        o.is_a?(ReturnNode)
      end
    end
  end
end
