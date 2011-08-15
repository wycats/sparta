module Sparta
  module Runtime
    def self.runtime_binding
      binding
    end

    class Descriptor
      attr_accessor :spec_Value, :spec_Writable, :spec_Enumerable, :spec_Configurable
    end

    # Create a shared literal descriptor to use for new properties in
    # an object literal
    LITERAL_DESCRIPTOR = Descriptor.new
    LITERAL_DESCRIPTOR.spec_Writable = true
    LITERAL_DESCRIPTOR.spec_Enumerable = true
    LITERAL_DESCRIPTOR.spec_Configurable = true

    class Object < Rubinius::LookupTable

      attr_accessor :spec_Prototype, :spec_Class

      def spec_Get(name)
        self[name]
      end

      def spec_Put(name, object, throw=false)
        self[name] = object
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

    class LiteralObject < Object
      thunk_method :spec_Prototype, OBJECT_PROTOTYPE
      thunk_method :spec_Class, "Object"
      thunk_method :spec_Extensible, true
    end

    class PromotedPrimitive < Object
      attr_accessor :internal_PrimitiveValue
    end
  end
end
