module Sparta
  module Runtime
    def self.runtime_binding
      binding
    end

    class Object < Rubinius::LookupTable
      attr_accessor :spec_Prototype, :spec_Class

      def spec_Get(name)
        self[name]
      end

      def spec_Put(name, object, throw=false)
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

    class Window < Object
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
