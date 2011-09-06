module Sparta
  module Runtime
    def self.runtime_binding
      binding
    end

    module Utils
      def self.ToString(object)
        object.to_s
      end

      def self.brackets(object, name)
        name = ToString(name)

        if object.is_a?(Object)
          object.get(name)
        else
          object.send(name)
        end
      end

      def self.typeof(resolve, name)
        if resolve == undefined
          "undefined"
        else
          val = resolve ? resolve.get(name) : name

          # TODO: Deal with host objects
          case val
          when undefined
            "undefined"
          when nil
            "object"
          when TrueClass, FalseClass
            "boolean"
          when Numeric
            "number"
          when String
            "string"
          when Function
            "function"
          else
            "object"
          end
        end
      end
    end

    # Object protocol:
    #
    # get(name<Symbol>)        => object
    # get_index(index<Fixnum>) => object
    # put(name<Symbol>, object<Object>)
    #

    class Object < Rubinius::LookupTable
      attr_accessor :prototype, :js_class

      def self.with_constructor(constructor)
        object = new
        object.prototype = constructor.get(:prototype)
        constructor.call_with(object)
        object
      end

      dynamic_method(:undefined) do |g|
        g.push_undef
        g.ret
      end

      def function(name, block=name)
        block = method(block) if block.is_a?(Symbol)

        self[name] = Function.new(block)
      end

      def to_hash
        Hash[*keys.zip(values).flatten]
      end

      def inspect
        "#<#{js_class} #{object_id.to_s(16)} #{to_hash.inspect}>"
      end

      def get(name)
        if self.key?(name)
          self[name]
        elsif proto = prototype
          proto.get(name)
        else
          undefined
        end
      end

      def get_index(index)
        get(Utils.ToString(index))
      end

      def put(name, object, throw=false)
        self[name] = object
      end

      def literal_put(name, object)
        put(name, object)

        # this method is called repeatedly to create new
        # properties for a literal. Return self so we
        # can just call literal_put again without
        # having to make sure the object we're creating
        # is on the stack using bytecode. 
        self
      end

      def can_put?(name)
        true
      end

      def has_property?(name)
        if result = key?(name)
          result
        elsif proto = prototype
          proto.has_property?(name)
        else
          false
        end
      end

      def delete_property(name)
        delete(name)
      end

      def default_value(hint)
        # TODO: This returns stuff like [object Object] which
        # is used by implementations to determine the true type
      end

      def self.empty_object
        obj                 = allocate
        obj.prototype  = OBJECT_PROTOTYPE
        obj.js_class      = "Object"
        obj.extensible = true
      end
    end

    OBJECT_PROTOTYPE = Runtime::Object.new
    ARRAY_PROTOTYPE  = Runtime::Object.new

    class Array < Object
      thunk_method :prototype, ARRAY_PROTOTYPE
      thunk_method :js_class, "Array"
      thunk_method :extensible, true

      def initialize(array)
        @array = array
      end

      def get_index(index)
        if index >= @array.size
          undefined
        else
          @array[index]
        end
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
      thunk_method :js_class, "Function"

      def self.for_block(&block)
        new(block.block)
      end

      def initialize(block)
        @block = block
      end

      def call(*args)
        @block.call(*args)
      end

      def call_with(this, *args)
        @block.call_under(this, @block.static_scope, *args)
      end
    end

    OBJECT_PROTOTYPE[:hasOwnProperty] = Function.for_block do |key|
      key?(key.to_sym)
    end

    class LiteralObject < Object
      thunk_method :prototype, OBJECT_PROTOTYPE
      thunk_method :js_class, "Object"
      thunk_method :extensible, true
    end

    class PromotedPrimitive < Object
      attr_accessor :primitive_value
    end
  end
end
