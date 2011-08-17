require "sparta/compilers/eval_compiler"
require "sparta/runtime/object"

module Sparta
  class Environment
    def initialize
      @window = Sparta::Runtime::Window.new
    end

    def eval(string)
      parser = RKelly::Parser.new
      ast    = parser.parse(string)

      cm = Sparta::Compilers::EvalCompiler.new.compile(ast)
      b  = Sparta::Runtime.runtime_binding

      cm.scope = b.static_scope
      cm.name  = :script

      script = Rubinius::CompiledMethod::Script.new(cm, "(javascript)", true)
      script.eval_source = string

      cm.scope.script = script

      be = Rubinius::BlockEnvironment.new
      be.under_context b.variables, cm

      be.from_eval!
      be.set_eval_binding b
      be.call_on_instance(self)
    end
  end
end
