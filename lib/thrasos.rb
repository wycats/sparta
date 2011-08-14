require "thrasos/version"
require "rkelly"

module Thrasos
  class Scope
    attr_reader :variables, :generator
    alias g generator

    def initialize(generator)
      @variables = []
      @generator = generator
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

    def push_local(name)
      g.push_local slot_for(name)
    end
  end

  class Compiler < RKelly::Visitors::Visitor
    attr_reader :generator, :scope
    alias g generator
    alias s scope

    def initialize
      @generator = Rubinius::Generator.new
      @scope = Scope.new(@generator)
    end

    def generate(ast)
      accept ast
      g.local_names = s.variables
      g.local_count = s.variables.size
      g
    end

    def compile(ast)
      generate ast
      rbx_compiler = Rubinius::Compiler.new :encoded_bytecode, :compiled_method
      rbx_compiler.encoder.input generator
      rbx_compiler.run
    end

    def visit_SourceElementsNode(o)
      last_index = o.value.size - 1
      o.value.each_with_index do |x, i|
        @eof = last_index == i
        x.accept(self)
      end
      g.ret
    end

    def visit_FunctionExprNode(o)
      # TODO We need to handle arguments eventually ...
      body = o.function_body.value
      block = self.class.new.generate(body)
      block.for_block = true
      g.create_block block
    end

    def visit_FunctionCallNode(o)
      # TODO Handle arguments
      o.value.accept(self)
      g.send :call, 0
    end

    def visit_ExpressionStatementNode(o)
      o.value.accept(self)
      g.pop unless @eof
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
      s.set_local o.left.value
    end

    def visit_ResolveNode(o)
      s.push_local o.value
    end
  end

  def self.eval(string)
    parser = RKelly::Parser.new
    ast    = parser.parse(string)

    cm = Compiler.new.compile(ast)
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
