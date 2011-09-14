require "thor"

module RKelly
  module Visitors
    class PrettyASTVisitor < Visitor
      def initialize(*)
        super
        @shell = Thor::Base.shell.new
      end

      def with_padding(status, color=true)
        say_status status, "", color
        @shell.padding += 1
        yield
        @shell.padding -= 1
      end

      def say_status(status, message, log_status=true)
        spaces = "  " * (@shell.padding + 1)

        color = (status =~ /^@/) ? :blue : :green
        color = log_status.is_a?(Symbol) ? log_status : color

        status = @shell.set_color status, color, true if color

        STDOUT.puts "#{spaces}#{status} #{message}"
        STDOUT.flush
      end

      def binary(name, o)
        with_padding(name) do
          with_padding("@left") { o.left.accept(self) }
          with_padding("@value") { o.value.accept(self) }
        end
      end

      def visit_SourceElementsNode(o)
        with_padding "SourceElements" do
          o.value.map { |x| x.accept(self) }
        end
      end

      def visit_VarStatementNode(o)
        with_padding "VarStatement" do
          o.value.map { |x| x.accept(self) }
        end
      end

      def visit_ConstStatementNode(o)
        with_padding "ConstStatement" do
          o.value.map { |x| x.accept(self) }
        end
      end

      def visit_VarDeclNode(o)
        with_padding "VarDecl" do
          say_status "@name", o.name
          o.value.accept(self) if o.value
        end
      end

      def visit_AssignExprNode(o)
        with_padding("AssignExpr") { super }
      end

      def visit_NumberNode(o)
        say_status "Number", o.value.to_s
      end

      def visit_ForNode(o)
        with_padding("For") do
          with_padding("@init") { o.init.accept(self) }
          with_padding("@test") { o.test.accept(self) }
          with_padding("@counter") { o.counter.accept(self) }
          o.value.accept(self)
        end
      end

      def visit_LessNode(o)
        binary("Less", o)
      end

      def visit_ResolveNode(o)
        say_status "Resolve", o.value
      end

      def visit_PostfixNode(o)
        with_padding("Postfix") do
          with_padding("@operand") { o.operand.accept(self) }
          say_status "@operator", o.value
        end
      end

      def visit_PrefixNode(o)
        with_padding("Prefix") do
          with_padding("@operand") { o.operand.accept(self) }
          say_status "@operator", o.value
        end
      end

      def visit_BlockNode(o)
        with_padding("Block") { super }
      end

      def visit_ExpressionStatementNode(o)
        with_padding("ExpressionStatement") { super }
      end

      def visit_OpEqualNode(o)
        binary("OpEqual", o)
      end

      def visit_FunctionCallNode(o)
        with_padding("FunctionCall") do
          with_padding("@arguments") { o.arguments.accept(self) }
          o.value.accept(self)
        end
      end

      def visit_ArgumentsNode(o)
        with_padding("Arguments") do
          o.value.map { |x| x.accept(self) }
        end
      end

      def visit_StringNode(o)
        say_status "String", o.value
      end

      def visit_NullNode(o)
        say_status "Null", ""
      end

      def visit_FunctionDeclNode(o)
        with_padding("FunctionDecl") do
          say_status "@name", o.value
          with_padding("@arguments") { o.arguments.map { |x| x.accept(self) } }
          with_padding("@function_body") { o.function_body.accept(self) }
        end
      end

      def visit_ParameterNode(o)
        say_status "Parameter", o.value
      end

      def visit_FunctionBodyNode(o)
        with_padding("FunctionBody") { super }
      end

      def visit_BreakNode(o)
        say_status "Break", o.value
      end

      def visit_ContinueNode(o)
        say_status "Continue", o.value
      end

      def visit_TrueNode(o)
        say_status "True", ""
      end

      def visit_FalseNode(o)
        say_status "False", ""
      end

      def visit_EmptyStatementNode(o)
        say_status "EmptyStatement", ""
      end

      def visit_RegexpNode(o)
        say_status "Regexp", o.value
      end

      def visit_DotAccessorNode(o)
        with_padding("DotAccessor") do
          say_status "@accessor", o.accessor
          super
        end
      end

      def visit_ThisNode(o)
        say_status "This", ""
      end

      def visit_BitwiseNotNode(o)
        with_padding("BitwiseNot") { super }
      end

      def visit_DeleteNode(o)
        with_padding("Delete") { super }
      end

      def visit_ArrayNode(o)
        with_padding("Array") { o.value.map { |x| x ? x.accept(self) : nil } }
      end

      def visit_ElementNode(o)
        with_padding("Element") { super }
      end

      def visit_LogicalNotNode(o)
        with_padding("LogicalNot") { super }
      end

      def visit_UnaryMinusNode(o)
        with_padding("UnaryMinus") { super }
      end

      def visit_UnaryPlusNode(o)
        with_padding("UnaryPlus") { super }
      end

      def visit_ReturnNode(o)
        if o.value
          with_padding("Return") { super }
        else
          say_status "Return", ""
        end
      end

      def visit_ThrowNode(o)
        with_padding("Throw") { super }
      end

      def visit_TypeOfNode(o)
        with_padding("TypeOf") { super }
      end

      def visit_VoidNode(o)
        with_padding("Void") { super }
      end

      [
        [:Add, '+'],
        [:BitAnd, '&'],
        [:BitOr, '|'],
        [:BitXOr, '^'],
        [:Divide, '/'],
        [:Equal, '=='],
        [:Greater, '>'],
        [:Greater, '>'],
        [:GreaterOrEqual, '>='],
        [:GreaterOrEqual, '>='],
        [:In, 'in'],
        [:InstanceOf, 'instanceof'],
        [:LeftShift, '<<'],
        [:LessOrEqual, '<='],
        [:LogicalAnd, '&&'],
        [:LogicalOr, '||'],
        [:Modulus, '%'],
        [:Multiply, '*'],
        [:NotEqual, '!='],
        [:NotStrictEqual, '!=='],
        [:OpAndEqual, '&='],
        [:OpDivideEqual, '/='],
        [:OpLShiftEqual, '<<='],
        [:OpMinusEqual, '-='],
        [:OpModEqual, '%='],
        [:OpMultiplyEqual, '*='],
        [:OpOrEqual, '|='],
        [:OpPlusEqual, '+='],
        [:OpRShiftEqual, '>>='],
        [:OpURShiftEqual, '>>>='],
        [:OpXOrEqual, '^='],
        [:RightShift, '>>'],
        [:StrictEqual, '==='],
        [:Subtract, '-'],
        [:UnsignedRightShift, '>>>'],
      ].each do |name,op|
        define_method(:"visit_#{name}Node") do |o|
          binary(name, o)
        end
      end

      def visit_WhileNode(o)
        binary("While", o)
      end

      def visit_SwitchNode(o)
        binary("Switch", o)
      end

      def visit_CaseBlockNode(o)
        with_padding("CaseBlock") do
          with_padding("@value") { o.value.map { |x| x.accept(self) } } if o.value
        end
      end

      def visit_CaseClauseNode(o)
        with_padding("CaseClause") do
          with_padding("@left") { o.left.accept(self) } if o.left
          o.value.accept(self)
        end
      end

      def visit_DoWhileNode(o)
        binary("DoWhile", o)
      end

      def visit_WithNode(o)
        binary("With", o)
      end

      def visit_LabelNode(o)
        with_padding("Label") do
          say_status "@name", o.name
          o.value.accept(self)
        end
      end

      def visit_ObjectLiteralNode(o)
        with_padding("ObjectLiteral") { super }
      end

      def visit_PropertyNode(o)
        with_padding("Property") do
          say_status "@name", o.name
          o.value.accept(self)
        end
      end

      #def visit_GetterPropertyNode(o)
        #"get #{o.name}#{o.value.accept(self)}"
      #end

      #def visit_SetterPropertyNode(o)
        #"set #{o.name}#{o.value.accept(self)}"
      #end

      def visit_FunctionExprNode(o)
        with_padding("FunctionExpr") do
          unless o.arguments.empty?
            with_padding("@arguments") do
              o.arguments.map { |x| x.accept(self) }
            end
          end

          with_padding("@function_body") do
            o.function_body.accept(self)
          end
        end
      end

      def visit_CommaNode(o)
        binary("Comma", o)
      end

      def visit_IfNode(o)
        with_padding("If") do
          with_padding("@conditions") { o.conditions.accept(self) }
          with_padding("@value") { o.value.accept(self) }
          with_padding("@else") { o.else.accept(self) } if o.else
        end
      end

      def visit_ConditionalNode(o)
        with_padding("Conditional") do
          with_padding("@conditions") { o.conditions.accept(self) }
          with_padding("@value") { o.value.accept(self) }
          with_padding("@else") { o.else.accept(self) }
        end
      end

      def visit_ForInNode(o)
        with_padding("ForIn") do
          with_padding("@left") { o.left.accept(self) }
          with_padding("@right") { o.right.accept(self) }
          o.value.accept(self)
        end
      end

      def visit_TryNode(o)
        with_padding("Try") do
          say_status "@catch_var", o.catch_var
          with_padding("@value") { o.value.accept(self) }
          with_padding("@catch_block") { o.catch_block.accept(self) }
          with_padding("@finally_block") { o.finally_block.accept(self) }
        end
      end

      def visit_BracketAccessorNode(o)
        with_padding("BracketAccessor") do
          with_padding("@accessor") { o.accessor.accept(self) }
          o.value.accept(self)
        end
      end

      def visit_NewExprNode(o)
        with_padding("NewExpr") do
          with_padding("@arguments") { o.arguments.accept(self) }
        end
        o.value.accept(self)
      end
    end
  end
end

