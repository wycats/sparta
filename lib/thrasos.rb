require "thrasos/version"
require "rkelly"

module Thrasos
  class Scope
    attr_reader :variables

    def initialize
      @variables = []
    end

    def slot_for(name)
      if existing = @variables.index(name)
        existing
      else
        @variables << name
        @variables.size - 1
      end
    end
  end

  class Compiler < RKelly::Visitors::Visitor
    attr_reader :generator
    alias g generator

    attr_reader :scope
    alias s scope

    def initialize
      @generator = Rubinius::Generator.new
      @scope = Scope.new
    end

    def compile(ast)
      accept ast

      g.local_names = s.variables
      g.local_count = s.variables.size

      rbx_compiler = Rubinius::Compiler.new :encoded_bytecode, :compiled_method
      rbx_compiler.encoder.input generator
      rbx_compiler.run
    end

    def visit_SourceElementsNode(o)
      o.value.each { |x| x.accept(self) }
      g.ret
    end

    def visit_ExpressionStatementNode(o)
      o.value.accept(self)
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
      g.set_local s.slot_for(o.left.value)
      g.pop
    end

    def visit_ResolveNode(o)
      g.push_local s.slot_for(o.value)
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
