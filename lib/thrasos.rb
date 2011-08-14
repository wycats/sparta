require "thrasos/version"
require "rkelly"

module Thrasos
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

    def set_local(name, depth = 0)
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

  class GlobalScope < Scope
    def initialize(generator)
      super(generator, nil)
    end

    def depth_for(name, depth = 0)
      [self, depth]
    end
  end

  class Compiler < RKelly::Visitors::Visitor
    attr_reader :generator, :scope
    alias g generator
    alias s scope

    def initialize(parent)
      @generator = Rubinius::Generator.new
      @scope = Scope.new(@generator, parent.scope)
    end

    # Receives an AST and returns a generator.
    def generate(ast)
      accept ast
      g.local_names = s.variables
      g.local_count = s.variables.size
      g
    end

    # Receives the AST and returns a Rubinius::CompiledMethod.
    def compile(ast)
      generate ast
      rbx_compiler = Rubinius::Compiler.new :encoded_bytecode, :compiled_method
      rbx_compiler.encoder.input generator
      rbx_compiler.run
    end

    def visit_SourceElementsNode(o)
      last_expr = o.value.last

      # Push a ReturnNode to the compiler if we don't have one yet.
      # TODO We are returning 0 right now, but this needs to be changed to undefined.
      # TODO Don't modify the tree inside the compiler, we need an ASTWalker to figure this out.
      if !last_expr || !last_expr.value.is_a?(RKelly::Nodes::ReturnNode)
        o.value <<
          RKelly::Nodes::ExpressionStatementNode.new(
            RKelly::Nodes::ReturnNode.new(
              RKelly::Nodes::NumberNode.new(0)
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
      # TODO We need to handle arguments eventually ...
      body = o.function_body.value
      block = Compiler.new(self).generate(body)
      block.for_block = true
      g.create_block block
    end

    def visit_FunctionCallNode(o)
      # TODO Handle arguments
      o.value.accept(self)
      g.send :call, 0
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
      o.value.accept(self)
      g.meta_send_op_plus g.find_literal(:+)
    end

    def visit_SubtractNode(o)
      o.left.accept(self)
      o.value.accept(self)
      g.meta_send_op_minus g.find_literal(:-)
    end

    def visit_MultiplyNode(o)
      o.left.accept(self)
      o.value.accept(self)
      g.send :*, 1
    end

    def visit_DivideNode(o)
      o.left.accept(self)
      g.send :to_f, 0
      o.value.accept(self)
      g.send :/, 1
    end

    def visit_UnaryPlusNode(o)
      o.value.accept(self)
    end

    def visit_UnaryMinusNode(o)
      value = o.value

      # If the underlying node is a number value
      # we can calculate the unary on Ruby land. Yay!
      if value.is_a?(RKelly::Nodes::NumberNode)
        g.push_int(-1 * value.value)
      else
        value.accept(self)
        g.push_int -1
        g.send :*, 1
      end
    end

    def visit_NumberNode(o)
      g.push_int o.value
    end

    def visit_OpEqualNode(o)
      o.value.accept(self)
      s.set_variable o.left.value
    end

    def visit_ResolveNode(o)
      s.push_variable o.value
    end

    private

    # Nodes that do not push value to the stack.
    # For example return, break and friends.
    def no_value_node?(o)
      o.is_a?(RKelly::Nodes::ReturnNode)
    end
  end

  class EvalCompiler < Compiler
    def initialize
      @generator = Rubinius::Generator.new
      @scope = GlobalScope.new(@generator)
    end

    # Automatically return the last expression unless
    # the last expression has no value. In this case,
    # it will return undefined.
    def visit_SourceElementsNode(o)
      last_expr = o.value.last
      if last_expr && !no_value_node?(last_expr.value)
        last_expr.value = RKelly::Nodes::ReturnNode.new(last_expr.value)
      end
      super
    end
  end

  def self.eval(string)
    parser = RKelly::Parser.new
    ast    = parser.parse(string)

    cm = EvalCompiler.new.compile(ast)
    b  = binding

    cm.scope = b.static_scope
    cm.name  = :script

    script = Rubinius::CompiledMethod::Script.new(cm, "(eval)", true)
    script.eval_source = string

    cm.scope.script = script

    be = Rubinius::BlockEnvironment.new
    be.under_context b.variables, cm

    be.from_eval!
    be.set_eval_binding b
    be.call_on_instance(b.self)
  end
end
