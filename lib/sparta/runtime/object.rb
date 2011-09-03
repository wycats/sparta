module Sparta
  module Runtime
    def self.runtime_binding
      binding
    end

    module Utils
      def self.brackets(object, name)
        if object.respond_to?(:coerce_Get)
          object.coerce_Get(name)
        else
          object.send(name)
        end
      end

      def self.spec_ToString(object)
        object.to_s
      end
    end

    class Object < Rubinius::LookupTable
      attr_accessor :spec_Prototype, :spec_Class

      def self.with_constructor(constructor)
        object = new
        object.spec_Prototype = constructor.spec_Get(:prototype)
        constructor.call_with(object)
        object
      end

      def function(name, block=name)
        block = method(block) if block.is_a?(Symbol)

        self[name] = Function.new(block)
      end

      def to_hash
        Hash[*keys.zip(values).flatten]
      end

      def inspect
        "#<#{spec_Class} #{object_id.to_s(16)} #{to_hash.inspect}>"
      end

      def spec_Get(name)
        if value = self[name]
          value
        elsif prototype = spec_Prototype
          prototype.spec_Get(name)
        end
      end

      def coerce_Get(obj)
        name = Utils.spec_ToString(obj)
        spec_Get(name)
      end

      def index_Get(index)
        spec_Get(Utils.spec_ToString(index))
      end

      def spec_Put(name, object, throw=false)
        self[name] = object
      end

      def internal_Put(name, object)
        self[name] = object
      end

      def internal_LiteralPut(name, object)
        self[name] = object

        # this method is called repeatedly to create new
        # properties for a literal. Return self so we
        # can just call internal_LiteralPut again without
        # having to make sure the object we're creating
        # is on the stack using bytecode. 
        self
      end

      def spec_CanPut(name)
        true
      end

      def spec_HasProperty(name)
        self.key?(name)
      end

      def spec_Delete(name)
        self.delete(name)
      end

      def spec_DefaultValue(hint)
        # TODO: This returns stuff like [object Object] which
        # is used by implementations to determine the true type
      end

      def spec_DefineOwnProperty(name, descriptor, throw=false)
        # TODO: This algorithm is actually pretty complicated.
        # For now, treat this like a simple [[Put]] operation.

        self[name] = descriptor.spec_Value
      end

      def self.empty_object
        obj                 = allocate
        obj.spec_Prototype  = OBJECT_PROTOTYPE
        obj.spec_Class      = "Object"
        obj.spec_Extensible = true
      end
    end

    OBJECT_PROTOTYPE = Runtime::Object.new
    ARRAY_PROTOTYPE  = Runtime::Object.new

    class Array < Object
      thunk_method :spec_Prototype, ARRAY_PROTOTYPE
      thunk_method :spec_Class, "Array"
      thunk_method :spec_Extensible, true

      def initialize(array)
        @array = array
      end

      def index_Get(index)
        @array[index]
      end

      def to_a
        @array
      end
    end

    class Window < Object
      def initialize
        function :p
      end
    end

    class Function < Object
      thunk_method :spec_Class, "Function"

      def initialize(block)
        @block = block
      end

      def call(*args)
        @block.call(*args)
      end

      def call_with(this, *args)
        @block.call_under(this, @block.static_scope)
      end
    end

    class LiteralObject < Object
      thunk_method :spec_Prototype, OBJECT_PROTOTYPE
      thunk_method :spec_Class, "Object"
      thunk_method :spec_Extensible, true
    end

    class PromotedPrimitive < Object
      attr_accessor :spec_PrimitiveValue
    end
  end
end
